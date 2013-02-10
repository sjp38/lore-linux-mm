Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id CBA6B6B0002
	for <linux-mm@kvack.org>; Sun, 10 Feb 2013 14:09:23 -0500 (EST)
Date: Sun, 10 Feb 2013 20:09:21 +0100
From: Pavel Machek <pavel@denx.de>
Subject: Re: PAE problems was [RFC] Reproducible OOM with just a few sleeps
Message-ID: <20130210190921.GA18384@amd.pavel.ucw.cz>
References: <201302010313.r113DTj3027195@como.maths.usyd.edu.au>
 <510B46C3.5040505@turmel.org>
 <20130201102044.GA2801@amd.pavel.ucw.cz>
 <20130201102545.GA3053@amd.pavel.ucw.cz>
 <5112F518.3020003@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5112F518.3020003@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Phil Turmel <philip@turmel.org>, "H. Peter Anvin" <hpa@zytor.com>, paul.szabo@sydney.edu.au, ben@decadent.org.uk, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed 2013-02-06 16:28:08, Dave Hansen wrote:
> On 02/01/2013 02:25 AM, Pavel Machek wrote:
> > Ouch, and... IIRC (hpa should know for sure), PAE is neccessary for
> > R^X support on x86, thus getting more common, not less. If it does not
> > work, that's bad news.
> 
> Dare I ask what "R^X" is?

Read xor Execute, aka NX.... support for executable but not readable
pages. Usefull for making exploits harder iirc.
									Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
