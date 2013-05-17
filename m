Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 693106B0033
	for <linux-mm@kvack.org>; Fri, 17 May 2013 01:43:56 -0400 (EDT)
Message-ID: <5195C37F.4090302@zytor.com>
Date: Thu, 16 May 2013 22:43:27 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [PATCH v6 0/8] kdump, vmcore: support mmap() on /proc/vmcore
References: <20130515090507.28109.28956.stgit@localhost6.localdomain6> <51957469.2000008@zytor.com> <87y5bee2qc.fsf@xmission.com> <5195A223.2070204@zytor.com> <87vc6icjqo.fsf@xmission.com>
In-Reply-To: <87vc6icjqo.fsf@xmission.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: HATAYAMA Daisuke <d.hatayama@jp.fujitsu.com>, vgoyal@redhat.com, akpm@linux-foundation.org, cpw@sgi.com, kumagai-atsushi@mxc.nes.nec.co.jp, lisa.mitchell@hp.com, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, zhangyanfei@cn.fujitsu.com, jingbai.ma@hp.com, linux-mm@kvack.org, riel@redhat.com, walken@google.com, hughd@google.com, kosaki.motohiro@jp.fujitsu.com

On 05/16/2013 09:29 PM, Eric W. Biederman wrote:
> 
> Whatever theoretical issues you have with /dev/oldmem and /proc/vmcore
> can and should be talked about and addressed independently of these
> changes.

And they are... last I know Dave Hansen was looking at it.

	-hpa


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
