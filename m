Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id C23EA6B0004
	for <linux-mm@kvack.org>; Mon, 21 Jan 2013 13:21:02 -0500 (EST)
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dave@linux.vnet.ibm.com>;
	Mon, 21 Jan 2013 13:21:01 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id C6DC3C90048
	for <linux-mm@kvack.org>; Mon, 21 Jan 2013 13:18:48 -0500 (EST)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r0LIIkOj236350
	for <linux-mm@kvack.org>; Mon, 21 Jan 2013 13:18:46 -0500
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r0LIIYPR018220
	for <linux-mm@kvack.org>; Mon, 21 Jan 2013 11:18:36 -0700
Message-ID: <50FD8676.9090203@linux.vnet.ibm.com>
Date: Mon, 21 Jan 2013 10:18:30 -0800
From: Dave Hansen <dave@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 4/5] create slow_virt_to_phys()
References: <20130121175244.E5839E06@kernel.stglabs.ibm.com> <20130121175249.AFE9EAD7@kernel.stglabs.ibm.com> <2ad09c09-98c3-4b2d-9b3f-f16fbcce4edf@email.android.com>
In-Reply-To: <2ad09c09-98c3-4b2d-9b3f-f16fbcce4edf@email.android.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Gleb Natapov <gleb@redhat.com>, x86@kernel.org, Marcelo Tosatti <mtosatti@redhat.com>, Rik van Riel <riel@redhat.com>

On 01/21/2013 10:08 AM, H. Peter Anvin wrote:
> Why are you initializing psize/pmask?

It's an artifact from the switch() that was there before.  I'll clean it up.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
