Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id D3FC56B0032
	for <linux-mm@kvack.org>; Thu, 16 May 2013 23:21:34 -0400 (EDT)
Message-ID: <5195A223.2070204@zytor.com>
Date: Thu, 16 May 2013 20:21:07 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [PATCH v6 0/8] kdump, vmcore: support mmap() on /proc/vmcore
References: <20130515090507.28109.28956.stgit@localhost6.localdomain6> <51957469.2000008@zytor.com> <87y5bee2qc.fsf@xmission.com>
In-Reply-To: <87y5bee2qc.fsf@xmission.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: HATAYAMA Daisuke <d.hatayama@jp.fujitsu.com>, vgoyal@redhat.com, akpm@linux-foundation.org, cpw@sgi.com, kumagai-atsushi@mxc.nes.nec.co.jp, lisa.mitchell@hp.com, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, zhangyanfei@cn.fujitsu.com, jingbai.ma@hp.com, linux-mm@kvack.org, riel@redhat.com, walken@google.com, hughd@google.com, kosaki.motohiro@jp.fujitsu.com

On 05/16/2013 07:53 PM, Eric W. Biederman wrote:
> 
> That is completely and totally orthogonal to this change.
> 
> read_oldmem may have problems but in practice on a large systems those
> problems are totally dwarfed by real life performance issues that come
> from playing too much with the page tables.
> 
> I really don't find bringing up whatever foundational issues you have
> with read_oldmem() appropriate or relevant here.
> 

Well, it is in the sense that we have two pieces of code doing the same
thing, each with different bugs.

	-hpa


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
