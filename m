Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id A11EF6B13F0
	for <linux-mm@kvack.org>; Mon, 13 Feb 2012 09:52:54 -0500 (EST)
From: Dan Smith <danms@us.ibm.com>
Subject: Re: [PATCH] Ensure that walk_page_range()'s start and end are page-aligned
References: <1328902796-30389-1-git-send-email-danms@us.ibm.com>
	<alpine.DEB.2.00.1202130211400.4324@chino.kir.corp.google.com>
Date: Mon, 13 Feb 2012 06:52:52 -0800
In-Reply-To: <alpine.DEB.2.00.1202130211400.4324@chino.kir.corp.google.com>
	(David Rientjes's message of "Mon, 13 Feb 2012 02:12:21 -0800 (PST)")
Message-ID: <87zkcm23az.fsf@caffeine.danplanet.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

DR> It doesn't "ensure" anything without CONFIG_DEBUG_VM enabled, which
DR> isn't the default.

Are you proposing a change in verbiage or a stronger check? A
VM_BUG_ON() seemed on par with other checks, such as the one in
get_user_pages_fast().

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
