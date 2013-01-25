Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 181B06B000C
	for <linux-mm@kvack.org>; Fri, 25 Jan 2013 18:16:05 -0500 (EST)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dave@linux.vnet.ibm.com>;
	Fri, 25 Jan 2013 18:16:03 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id E8A906E803C
	for <linux-mm@kvack.org>; Fri, 25 Jan 2013 18:15:58 -0500 (EST)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r0PNFxDj341510
	for <linux-mm@kvack.org>; Fri, 25 Jan 2013 18:16:00 -0500
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r0PNFw5A001159
	for <linux-mm@kvack.org>; Fri, 25 Jan 2013 16:15:59 -0700
Message-ID: <51031227.6010000@linux.vnet.ibm.com>
Date: Fri, 25 Jan 2013 15:15:51 -0800
From: Dave Hansen <dave@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/5] [v3] fix illegal use of __pa() in KVM code
References: <20130122212428.8DF70119@kernel.stglabs.ibm.com>
In-Reply-To: <20130122212428.8DF70119@kernel.stglabs.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Gleb Natapov <gleb@redhat.com>, "H.Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Marcelo Tosatti <mtosatti@redhat.com>, Rik van Riel <riel@redhat.com>

On 01/22/2013 01:24 PM, Dave Hansen wrote:
> This series fixes a hard-to-debug early boot hang on 32-bit
> NUMA systems.  It adds coverage to the debugging code,
> adds some helpers, and eventually fixes the original bug I
> was hitting.

I got one more reviewed-by on this set, but otherwise no more comments.
 Could these get pulled in to the x86 tree for merging in 3.9?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
