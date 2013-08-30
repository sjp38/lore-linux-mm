Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 9DBEF6B0033
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 02:14:21 -0400 (EDT)
Received: by mail-wi0-f182.google.com with SMTP id ey11so1367898wid.15
        for <linux-mm@kvack.org>; Thu, 29 Aug 2013 23:14:20 -0700 (PDT)
Date: Fri, 30 Aug 2013 09:14:15 +0300
From: Dan Aloni <alonid@stratoscale.com>
Subject: Re: [PATCH] x86: e820: fix memmap kernel boot parameter
Message-ID: <20130830061413.GA29949@gmail.com>
References: <1377841673-17361-1-git-send-email-bob.liu@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1377841673-17361-1-git-send-email-bob.liu@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, hpa@linux.intel.com, yinghai@kernel.org, jacob.shin@amd.com, konrad.wilk@oracle.com, linux-mm@kvack.org, Bob Liu <bob.liu@oracle.com>

On Fri, Aug 30, 2013 at 01:47:53PM +0800, Bob Liu wrote:
>[..]
> Machine2: bootcmdline in grub.cfg "memmap=0x77ffffff$0x880000000", the result of
> "cat /proc/cmdline" changed to "memmap=0x77ffffffx880000000".
> 
> I didn't find the root cause, I think maybe grub reserved "$0" as something
> special.
> Replace '$' with '%' in kernel boot parameter can fix this issue.

You are correct with the root cause, however I don't think the patch is needed.

In order to bypass grub's variable evaluation you can simply use escaping 
and replace $ with \$ in your grub config.

-- 
Dan Aloni

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
