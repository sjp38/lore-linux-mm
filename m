Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id 176226B0002
	for <linux-mm@kvack.org>; Mon, 21 Jan 2013 13:59:51 -0500 (EST)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dave@linux.vnet.ibm.com>;
	Mon, 21 Jan 2013 13:59:50 -0500
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id E3FED38C8045
	for <linux-mm@kvack.org>; Mon, 21 Jan 2013 13:59:47 -0500 (EST)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r0LIxlMn271840
	for <linux-mm@kvack.org>; Mon, 21 Jan 2013 13:59:47 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r0LIxkot026589
	for <linux-mm@kvack.org>; Mon, 21 Jan 2013 16:59:47 -0200
Message-ID: <50FD901C.8000002@linux.vnet.ibm.com>
Date: Mon, 21 Jan 2013 10:59:40 -0800
From: Dave Hansen <dave@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 5/5] fix kvm's use of __pa() on percpu areas
References: <20130121175244.E5839E06@kernel.stglabs.ibm.com> <20130121175250.1AAC7981@kernel.stglabs.ibm.com> <08cba1bf-6476-4fad-8d29-e380ec7127ba@email.android.com>
In-Reply-To: <08cba1bf-6476-4fad-8d29-e380ec7127ba@email.android.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Gleb Natapov <gleb@redhat.com>, x86@kernel.org, Marcelo Tosatti <mtosatti@redhat.com>, Rik van Riel <riel@redhat.com>

On 01/21/2013 10:38 AM, H. Peter Anvin wrote:
> Final question: are any of these done in frequent paths?  (I believe no, but...)

Nope.  All of the places that it gets used here are in
initialization-time paths.  The two we have here are when kvm and the
host are setting up a new vcpu and when the kvmclock clocksource is
being registered.  A CPU getting hotplugged is the only thing that might
even have these get called more than at boot.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
