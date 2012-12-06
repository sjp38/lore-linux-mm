Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 7B2CB6B00D5
	for <linux-mm@kvack.org>; Thu,  6 Dec 2012 17:50:22 -0500 (EST)
Date: Thu, 6 Dec 2012 14:50:20 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC PATCH 0/8] remove vm_struct list management
Message-Id: <20121206145020.93fd7128.akpm@linux-foundation.org>
In-Reply-To: <1354810175-4338-1-git-send-email-js1304@gmail.com>
References: <1354810175-4338-1-git-send-email-js1304@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Russell King <rmk+kernel@arm.linux.org.uk>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kexec@lists.infradead.org, Vivek Goyal <vgoyal@redhat.com>

On Fri,  7 Dec 2012 01:09:27 +0900
Joonsoo Kim <js1304@gmail.com> wrote:

> I'm not sure that "7/8: makes vmlist only for kexec" is fine.
> Because it is related to userspace program.
> As far as I know, makedumpfile use kexec's output information and it only
> need first address of vmalloc layer. So my implementation reflect this
> fact, but I'm not sure. And now, I don't fully test this patchset.
> Basic operation work well, but I don't test kexec. So I send this
> patchset with 'RFC'.

Yes, this is irritating.  Perhaps Vivek or one of the other kexec
people could take a look at this please - if would obviously be much
better if we can avoid merging [patch 7/8] at all.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
