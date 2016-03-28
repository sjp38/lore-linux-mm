Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 7C75B6B007E
	for <linux-mm@kvack.org>; Mon, 28 Mar 2016 13:14:00 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id fe3so102631644pab.1
        for <linux-mm@kvack.org>; Mon, 28 Mar 2016 10:14:00 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id mk10si4269128pab.219.2016.03.28.10.13.59
        for <linux-mm@kvack.org>;
        Mon, 28 Mar 2016 10:13:59 -0700 (PDT)
Date: Tue, 29 Mar 2016 01:12:38 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: fs/ocfs2/aops.c:1881:2-7: WARNING: NULL check before freeing
 functions like kfree, debugfs_remove, debugfs_remove_recursive or
 usb_free_urb is not needed. Maybe consider reorganizing relevant code to
 avoid passing NULL values.
Message-ID: <201603290135.boGSGJFw%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ryan Ding <ryan.ding@oracle.com>
Cc: kbuild-all@01.org, linux-kernel@vger.kernel.org, Junxiao Bi <junxiao.bi@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

tree:   https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master
head:   f55532a0c0b8bb6148f4e07853b876ef73bc69ca
commit: 4506cfb6f8cad594ac73e0df2b2961ca10dbd25e ocfs2: record UNWRITTEN extents when populate write desc
date:   3 days ago


coccinelle warnings: (new ones prefixed by >>)

>> fs/ocfs2/aops.c:1881:2-7: WARNING: NULL check before freeing functions like kfree, debugfs_remove, debugfs_remove_recursive or usb_free_urb is not needed. Maybe consider reorganizing relevant code to avoid passing NULL values.

vim +1881 fs/ocfs2/aops.c

  1865				ret = -ENOMEM;
  1866				goto out;
  1867			}
  1868			goto retry;
  1869		}
  1870		/* This direct write will doing zero. */
  1871		new->ue_cpos = desc->c_cpos;
  1872		new->ue_phys = desc->c_phys;
  1873		desc->c_clear_unwritten = 0;
  1874		list_add_tail(&new->ue_ip_node, &oi->ip_unwritten_list);
  1875		list_add_tail(&new->ue_node, &wc->w_unwritten_list);
  1876		new = NULL;
  1877	unlock:
  1878		spin_unlock(&oi->ip_lock);
  1879	out:
  1880		if (new)
> 1881			kfree(new);
  1882		return ret;
  1883	}
  1884	
  1885	/*
  1886	 * Populate each single-cluster write descriptor in the write context
  1887	 * with information about the i/o to be done.
  1888	 *
  1889	 * Returns the number of clusters that will have to be allocated, as

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
