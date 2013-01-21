Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id F12D16B0004
	for <linux-mm@kvack.org>; Mon, 21 Jan 2013 14:24:59 -0500 (EST)
In-Reply-To: <50FD901C.8000002@linux.vnet.ibm.com>
References: <20130121175244.E5839E06@kernel.stglabs.ibm.com> <20130121175250.1AAC7981@kernel.stglabs.ibm.com> <08cba1bf-6476-4fad-8d29-e380ec7127ba@email.android.com> <50FD901C.8000002@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 8bit
Subject: Re: [PATCH 5/5] fix kvm's use of __pa() on percpu areas
From: "H. Peter Anvin" <hpa@zytor.com>
Date: Mon, 21 Jan 2013 13:22:50 -0600
Message-ID: <6a43e949-61b2-4d96-8e85-46de3da8c3d0@email.android.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Gleb Natapov <gleb@redhat.com>, x86@kernel.org, Marcelo Tosatti <mtosatti@redhat.com>, Rik van Riel <riel@redhat.com>

Cool, just checking.

Dave Hansen <dave@linux.vnet.ibm.com> wrote:

>On 01/21/2013 10:38 AM, H. Peter Anvin wrote:
>> Final question: are any of these done in frequent paths?  (I believe
>no, but...)
>
>Nope.  All of the places that it gets used here are in
>initialization-time paths.  The two we have here are when kvm and the
>host are setting up a new vcpu and when the kvmclock clocksource is
>being registered.  A CPU getting hotplugged is the only thing that
>might
>even have these get called more than at boot.

-- 
Sent from my mobile phone. Please excuse brevity and lack of formatting.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
