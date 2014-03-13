Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 76CE96B0035
	for <linux-mm@kvack.org>; Thu, 13 Mar 2014 19:45:07 -0400 (EDT)
Received: by mail-wi0-f179.google.com with SMTP id f8so1887922wiw.0
        for <linux-mm@kvack.org>; Thu, 13 Mar 2014 16:45:06 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id wg1si2649804wjb.115.2014.03.13.16.45.04
        for <linux-mm@kvack.org>;
        Thu, 13 Mar 2014 16:45:05 -0700 (PDT)
Date: Thu, 13 Mar 2014 19:44:38 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <53224301.c19cc20a.23d5.7ed5SMTPIN_ADDED_BROKEN@mx.google.com>
In-Reply-To: <3908561D78D1C84285E8C5FCA982C28F31E04DD3@ORSMSX106.amr.corp.intel.com>
References: <1394746786-6397-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1394746786-6397-5-git-send-email-n-horiguchi@ah.jp.nec.com>
 <3908561D78D1C84285E8C5FCA982C28F31E04DD3@ORSMSX106.amr.corp.intel.com>
Subject: Re: [PATCH 4/6] fs/proc/page.c: introduce /proc/kpagecache interface
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tony.luck@intel.com
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, andi@firstfloor.org, fengguang.wu@intel.com, liwanp@linux.vnet.ibm.com, david@fromorbit.com, j-nomura@ce.jp.nec.com, linux-mm@kvack.org

On Thu, Mar 13, 2014 at 11:09:10PM +0000, Luck, Tony wrote:
> > Usage is simple: 1) write a file path to be scanned into the interface,
> > and 2) read 64-bit entries, each of which is associated with the page on
> > each page index.
> 
> Do we have other interfaces that work like that?

No, we don't. At first I thought of doing this under /proc/pid, but that did
not work because we want to scan the files which no process opens.

> I suppose this is file is only open
> to "root", so it may be safe to assume that applications using this won't stomp on
> each other.

Right, this is only for testing/debugging purpose (at least for now) so
limiting access is safe.

Thanks,
Naoya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
