Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id AD88A6B0038
	for <linux-mm@kvack.org>; Fri, 20 Oct 2017 19:25:58 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id q42so6453140wrb.3
        for <linux-mm@kvack.org>; Fri, 20 Oct 2017 16:25:58 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id o13sor668116wmg.65.2017.10.20.16.25.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 20 Oct 2017 16:25:57 -0700 (PDT)
Subject: Re: [PATCH 00/23] Hardened usercopy whitelisting
From: Paolo Bonzini <pbonzini@redhat.com>
References: <1497915397-93805-1-git-send-email-keescook@chromium.org>
 <0ad1f8b1-3c9f-adb0-35c3-18619ff5aa25@redhat.com>
Message-ID: <0015a75a-3624-2ec7-ae21-4753cf072e61@redhat.com>
Date: Sat, 21 Oct 2017 01:25:55 +0200
MIME-Version: 1.0
In-Reply-To: <0ad1f8b1-3c9f-adb0-35c3-18619ff5aa25@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>, kernel-hardening@lists.openwall.com
Cc: David Windsor <dave@nullcore.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 21/10/2017 00:40, Paolo Bonzini wrote:
> This breaks KVM completely on x86, due to two ioctls
> (KVM_GET/SET_CPUID2) accessing the cpuid_entries field of struct
> kvm_vcpu_arch.
> 
> There's also another broken ioctl, KVM_XEN_HVM_CONFIG, but it is
> obsolete and not a big deal at all.
> 
> I can post some patches, but probably not until the beginning of
> November due to travelling.  Please do not send this too close to the
> beginning of the merge window.

Sleeping is overrated, sending patches now...

Paolo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
