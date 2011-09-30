Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0828B9000BD
	for <linux-mm@kvack.org>; Fri, 30 Sep 2011 18:47:28 -0400 (EDT)
Message-ID: <4E8646F8.8090109@zytor.com>
Date: Fri, 30 Sep 2011 15:47:20 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [RFCv2][PATCH 1/4] break units out of string_get_size()
References: <20110930203219.60D507CB@kernel>  <4E8634D3.2080504@zytor.com> <1317422761.16137.669.camel@nimitz>
In-Reply-To: <1317422761.16137.669.camel@nimitz>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, rientjes@google.com, James.Bottomley@HansenPartnership.com

On 09/30/2011 03:46 PM, Dave Hansen wrote:
> 
> ... or the 'i' for that matter.
> 

The "i" you need in the array unless you want to say "500 iB" and the
like, or have special logic for it.

	-hpa


-- 
H. Peter Anvin, Intel Open Source Technology Center
I work for Intel.  I don't speak on their behalf.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
