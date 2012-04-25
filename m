Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id A32646B0044
	for <linux-mm@kvack.org>; Wed, 25 Apr 2012 12:38:19 -0400 (EDT)
Received: from /spool/local
	by e3.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Wed, 25 Apr 2012 12:38:16 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 3F2F438C803A
	for <linux-mm@kvack.org>; Wed, 25 Apr 2012 12:38:01 -0400 (EDT)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q3PGbxa6046258
	for <linux-mm@kvack.org>; Wed, 25 Apr 2012 12:37:59 -0400
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q3PGbwXO028036
	for <linux-mm@kvack.org>; Wed, 25 Apr 2012 10:37:59 -0600
Message-ID: <4F982862.4050302@linux.vnet.ibm.com>
Date: Wed, 25 Apr 2012 11:37:54 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 6/6] zsmalloc: make zsmalloc portable
References: <1335334994-22138-1-git-send-email-minchan@kernel.org> <1335334994-22138-7-git-send-email-minchan@kernel.org> <4F980AFE.60901@vflare.org>
In-Reply-To: <4F980AFE.60901@vflare.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Nitin Gupta <ngupta@vflare.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hey Minchan,

Thanks for the patches!

On 04/25/2012 09:32 AM, Nitin Gupta wrote:
> I think Seth was working on this improvement but not sure about the
> current status. Seth?

Yes, I looked at this option, and it is very clean and portable.

Unfortunately, IIRC, with our rate of mapping/unmapping,
flush_tlb_kernel_range() causes an IPI storm that effective
stalls the machine.

I'll apply your patch and try it out.

Thanks,
Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
