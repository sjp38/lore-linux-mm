Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 92FA36B0005
	for <linux-mm@kvack.org>; Wed,  6 Feb 2013 19:29:00 -0500 (EST)
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dave@linux.vnet.ibm.com>;
	Wed, 6 Feb 2013 19:28:59 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 599A86E8047
	for <linux-mm@kvack.org>; Wed,  6 Feb 2013 19:28:12 -0500 (EST)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r170SD9p291844
	for <linux-mm@kvack.org>; Wed, 6 Feb 2013 19:28:13 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r170SCuD019805
	for <linux-mm@kvack.org>; Wed, 6 Feb 2013 22:28:13 -0200
Message-ID: <5112F518.3020003@linux.vnet.ibm.com>
Date: Wed, 06 Feb 2013 16:28:08 -0800
From: Dave Hansen <dave@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: PAE problems was [RFC] Reproducible OOM with just a few sleeps
References: <201302010313.r113DTj3027195@como.maths.usyd.edu.au> <510B46C3.5040505@turmel.org> <20130201102044.GA2801@amd.pavel.ucw.cz> <20130201102545.GA3053@amd.pavel.ucw.cz>
In-Reply-To: <20130201102545.GA3053@amd.pavel.ucw.cz>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Machek <pavel@denx.de>
Cc: Phil Turmel <philip@turmel.org>, "H. Peter Anvin" <hpa@zytor.com>, paul.szabo@sydney.edu.au, ben@decadent.org.uk, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 02/01/2013 02:25 AM, Pavel Machek wrote:
> Ouch, and... IIRC (hpa should know for sure), PAE is neccessary for
> R^X support on x86, thus getting more common, not less. If it does not
> work, that's bad news.

Dare I ask what "R^X" is?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
