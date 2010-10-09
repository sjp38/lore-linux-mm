Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id C0FD56B0071
	for <linux-mm@kvack.org>; Sat,  9 Oct 2010 14:44:35 -0400 (EDT)
Message-ID: <4CB0B803.3040008@redhat.com>
Date: Sat, 09 Oct 2010 20:44:19 +0200
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v6 07/12] Add async PF initialization to PV guest.
References: <1286207794-16120-1-git-send-email-gleb@redhat.com> <1286207794-16120-8-git-send-email-gleb@redhat.com> <4CADC229.9040402@redhat.com> <20101008075414.GB8354@redhat.com>
In-Reply-To: <20101008075414.GB8354@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Gleb Natapov <gleb@redhat.com>
Cc: kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mingo@elte.hu, a.p.zijlstra@chello.nl, tglx@linutronix.de, hpa@zytor.com, riel@redhat.com, cl@linux-foundation.org, mtosatti@redhat.com
List-ID: <linux-mm.kvack.org>

  On 10/08/2010 09:54 AM, Gleb Natapov wrote:
> >  >+
> >  >+static void kvm_guest_cpu_notify(void *dummy)
> >  >+{
> >  >+	if (!dummy)
> >  >+		kvm_guest_cpu_init();
> >  >+	else
> >  >+		kvm_pv_disable_apf(NULL);
> >  >+}
> >
> >  Why are you making decisions based on a dummy input?
> >
> >  The whole thing looks strange.  Use two functions?
> >
> What is so strange? Type of notification is passed as a parameter.
> The code that does this is just under the function. I can rename
> dummy to something else. Or make it two functions.

Two separate functions is simplest.

-- 
I have a truly marvellous patch that fixes the bug which this
signature is too narrow to contain.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
