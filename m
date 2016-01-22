Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id C18876B0005
	for <linux-mm@kvack.org>; Fri, 22 Jan 2016 16:31:16 -0500 (EST)
Received: by mail-pa0-f43.google.com with SMTP id yy13so47407638pab.3
        for <linux-mm@kvack.org>; Fri, 22 Jan 2016 13:31:16 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id r70si11924479pfr.123.2016.01.22.13.31.15
        for <linux-mm@kvack.org>;
        Fri, 22 Jan 2016 13:31:15 -0800 (PST)
Subject: Re: [PATCH] mm, gup: introduce concept of "foreign" get_user_pages()
References: <201601230229.C4kUiPa1%fengguang.wu@intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <56A29FA2.5090409@intel.com>
Date: Fri, 22 Jan 2016 13:31:14 -0800
MIME-Version: 1.0
In-Reply-To: <201601230229.C4kUiPa1%fengguang.wu@intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>
Cc: kbuild-all@01.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, dave.hansen@linux.intel.com, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, aarcange@redhat.com, n-horiguchi@ah.jp.nec.com, srikar@linux.vnet.ibm.com, vbabka@suse.cz, jack@suse.cz

On 01/22/2016 10:16 AM, kbuild test robot wrote:
> [auto build test ERROR on next-20160122]
> [also build test ERROR on v4.4]
> [cannot apply to drm/drm-next linuxtv-media/master v4.4-rc8 v4.4-rc7 v4.4-rc6]
> [if your patch is applied to the wrong git tree, please drop us a note to help improving the system]

Heh, good job lkp. :)

For the others on this thread, my build testing was screwed up and I was
missing the nommu builds.  Should be fixed up from here on out.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
