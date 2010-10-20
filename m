Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 2CFAB6B009E
	for <linux-mm@kvack.org>; Wed, 20 Oct 2010 07:33:13 -0400 (EDT)
Date: Wed, 20 Oct 2010 13:33:00 +0200
From: Gleb Natapov <gleb@redhat.com>
Subject: Re: [PATCH v7 02/12] Halt vcpu if page it tries to access is
 swapped out.
Message-ID: <20101020113300.GR10207@redhat.com>
References: <1287048176-2563-1-git-send-email-gleb@redhat.com>
 <1287048176-2563-3-git-send-email-gleb@redhat.com>
 <4CBED271.9000103@siemens.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4CBED271.9000103@siemens.com>
Sender: owner-linux-mm@kvack.org
To: Jan Kiszka <jan.kiszka@siemens.com>
Cc: kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, avi@redhat.com, mingo@elte.hu, a.p.zijlstra@chello.nl, tglx@linutronix.de, hpa@zytor.com, riel@redhat.com, cl@linux-foundation.org, mtosatti@redhat.com
List-ID: <linux-mm.kvack.org>

On Wed, Oct 20, 2010 at 01:28:49PM +0200, Jan Kiszka wrote:
> 
> Based on early kvm-kmod experiments, it looks like this (and maybe more)
> breaks the build in arch/x86/kvm/x86.c if CONFIG_KVM_ASYNC_PF is
> disabled. Please have a look.
> 
CONFIG_KVM_ASYNC_PF is always enabled on x86.

--
			Gleb.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
