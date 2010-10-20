Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id D2AC96B009E
	for <linux-mm@kvack.org>; Wed, 20 Oct 2010 07:36:17 -0400 (EDT)
Message-ID: <4CBED41F.6030109@siemens.com>
Date: Wed, 20 Oct 2010 13:35:59 +0200
From: Jan Kiszka <jan.kiszka@siemens.com>
MIME-Version: 1.0
Subject: Re: [PATCH v7 02/12] Halt vcpu if page it tries to access is swapped
 out.
References: <1287048176-2563-1-git-send-email-gleb@redhat.com> <1287048176-2563-3-git-send-email-gleb@redhat.com> <4CBED271.9000103@siemens.com> <20101020113300.GR10207@redhat.com>
In-Reply-To: <20101020113300.GR10207@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Gleb Natapov <gleb@redhat.com>
Cc: "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "avi@redhat.com" <avi@redhat.com>, "mingo@elte.hu" <mingo@elte.hu>, "a.p.zijlstra@chello.nl" <a.p.zijlstra@chello.nl>, "tglx@linutronix.de" <tglx@linutronix.de>, "hpa@zytor.com" <hpa@zytor.com>, "riel@redhat.com" <riel@redhat.com>, "cl@linux-foundation.org" <cl@linux-foundation.org>, "mtosatti@redhat.com" <mtosatti@redhat.com>
List-ID: <linux-mm.kvack.org>

Am 20.10.2010 13:33, Gleb Natapov wrote:
> On Wed, Oct 20, 2010 at 01:28:49PM +0200, Jan Kiszka wrote:
>>
>> Based on early kvm-kmod experiments, it looks like this (and maybe more)
>> breaks the build in arch/x86/kvm/x86.c if CONFIG_KVM_ASYNC_PF is
>> disabled. Please have a look.
>>
> CONFIG_KVM_ASYNC_PF is always enabled on x86.

Ah, so this is more like CONFIG_HAVE_KVM_ASYNC_PF?

Then I need some stubs in kvm-kmod to handle the case that its disabled
on x86 (due to missing host kernel features).

Jan

-- 
Siemens AG, Corporate Technology, CT T DE IT 1
Corporate Competence Center Embedded Linux

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
