Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 3DE0F6B002C
	for <linux-mm@kvack.org>; Wed,  8 Feb 2012 20:13:43 -0500 (EST)
Received: by pbcwz17 with SMTP id wz17so1313849pbc.14
        for <linux-mm@kvack.org>; Wed, 08 Feb 2012 17:13:42 -0800 (PST)
Date: Wed, 8 Feb 2012 17:13:26 -0800
From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 3/5] staging: zcache: replace xvmalloc with zsmalloc
Message-ID: <20120209011326.GA2225@kroah.com>
References: <1326149520-31720-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <1326149520-31720-4-git-send-email-sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1326149520-31720-4-git-send-email-sjenning@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Greg Kroah-Hartman <gregkh@suse.de>, devel@driverdev.osuosl.org, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Wilk <konrad.wilk@oracle.com>, linux-kernel@vger.kernel.org, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, Brian King <brking@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>

On Mon, Jan 09, 2012 at 04:51:58PM -0600, Seth Jennings wrote:
> Replaces xvmalloc with zsmalloc as the persistent memory allocator
> for zcache
> 
> Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>

This patch no longer applies :(

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
