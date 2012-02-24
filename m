Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id 7A6656B004A
	for <linux-mm@kvack.org>; Fri, 24 Feb 2012 16:03:13 -0500 (EST)
From: Dan Smith <danms@us.ibm.com>
Subject: Re: [PATCH] Ensure that walk_page_range()'s start and end are page-aligned
References: <1328902796-30389-1-git-send-email-danms@us.ibm.com>
	<alpine.DEB.2.00.1202130211400.4324@chino.kir.corp.google.com>
	<87zkcm23az.fsf@caffeine.danplanet.com>
	<alpine.DEB.2.00.1202131350500.17296@chino.kir.corp.google.com>
	<87obsoxcn6.fsf@danplanet.com>
	<20120224125519.89120828.akpm@linux-foundation.org>
Date: Fri, 24 Feb 2012 13:03:11 -0800
In-Reply-To: <20120224125519.89120828.akpm@linux-foundation.org> (Andrew
	Morton's message of "Fri, 24 Feb 2012 12:55:19 -0800")
Message-ID: <87k43cx7u8.fsf@danplanet.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, dave@linux.vnet.ibm.com

AM> Well...  why should we apply the patch?  Is there some buggy code
AM> which is triggering the problem?  Do you intend to write some buggy
AM> code to trigger the problem?  ;)

Well, I already did and it took me longer to figure out than it should
have :)

AM> Also, as it's a developer-only thing we should arrange for the
AM> overhead to vanish when CONFIG_DEBUG_VM=n?

Heh, if you like that flavor, see the previous version of the patch at
the top of this thread :)

-- 
Dan Smith
IBM Linux Technology Center
email: danms@us.ibm.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
