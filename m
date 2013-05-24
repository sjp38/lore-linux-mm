Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id B409F6B003B
	for <linux-mm@kvack.org>; Fri, 24 May 2013 09:12:31 -0400 (EDT)
Date: Fri, 24 May 2013 09:12:17 -0400
From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: [PATCH v8 3/9] vmcore: treat memory chunks referenced by PT_LOAD
 program header entries in page-size boundary in vmcore_list
Message-ID: <20130524131217.GA18218@redhat.com>
References: <20130523052421.13864.83978.stgit@localhost6.localdomain6>
 <20130523052513.13864.85440.stgit@localhost6.localdomain6>
 <20130523144928.0328bb3ad7ccc1ff2da9558d@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130523144928.0328bb3ad7ccc1ff2da9558d@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: HATAYAMA Daisuke <d.hatayama@jp.fujitsu.com>, ebiederm@xmission.com, cpw@sgi.com, kumagai-atsushi@mxc.nes.nec.co.jp, lisa.mitchell@hp.com, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, zhangyanfei@cn.fujitsu.com, jingbai.ma@hp.com, linux-mm@kvack.org, riel@redhat.com, walken@google.com, hughd@google.com, kosaki.motohiro@jp.fujitsu.com

On Thu, May 23, 2013 at 02:49:28PM -0700, Andrew Morton wrote:
> On Thu, 23 May 2013 14:25:13 +0900 HATAYAMA Daisuke <d.hatayama@jp.fujitsu.com> wrote:
> 
> > Treat memory chunks referenced by PT_LOAD program header entries in
> > page-size boundary in vmcore_list. Formally, for each range [start,
> > end], we set up the corresponding vmcore object in vmcore_list to
> > [rounddown(start, PAGE_SIZE), roundup(end, PAGE_SIZE)].
> > 
> > This change affects layout of /proc/vmcore.
> 
> Well, changing a userspace interface is generally unacceptable because
> it can break existing userspace code.
> 
> If you think the risk is acceptable then please do explain why.  In
> great detail!

I think it should not be a problem as /proc/vmcore is useful only when
one parses the elf headers and then accesses the contents of file based
on the header information. This patch just introduces additional areas
in /proc/vmcore file and ELF headers still point to right contents. So
any tool parsing ELF headers and then accessing file contents based on
that info should still be fine.

AFAIK, no user space tool should be broken there.

Thanks
Vivek

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
