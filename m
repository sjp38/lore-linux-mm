Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx207.postini.com [74.125.245.207])
	by kanga.kvack.org (Postfix) with SMTP id 1E97C6B0083
	for <linux-mm@kvack.org>; Wed, 29 Feb 2012 15:33:09 -0500 (EST)
Date: Wed, 29 Feb 2012 14:33:06 -0600 (CST)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: [RFC][PATCH] fix move/migrate_pages() race on task struct
In-Reply-To: <20120229123120.127e21fd.akpm@linux-foundation.org>
Message-ID: <alpine.DEB.2.00.1202291432350.6746@router.home>
References: <20120223180740.C4EC4156@kernel> <alpine.DEB.2.00.1202231240590.9878@router.home> <4F468F09.5050200@linux.vnet.ibm.com> <alpine.DEB.2.00.1202231334290.10914@router.home> <4F469BC7.50705@linux.vnet.ibm.com> <alpine.DEB.2.00.1202231536240.13554@router.home>
 <m1ehtkapn9.fsf@fess.ebiederm.org> <alpine.DEB.2.00.1202240859340.2621@router.home> <4F47BF56.6010602@linux.vnet.ibm.com> <alpine.DEB.2.00.1202241053220.3726@router.home> <alpine.DEB.2.00.1202241105280.3726@router.home> <4F47C800.4090903@linux.vnet.ibm.com>
 <alpine.DEB.2.00.1202241131400.3726@router.home> <87sjhzun47.fsf@xmission.com> <alpine.DEB.2.00.1202271238450.32410@router.home> <87d390janv.fsf@xmission.com> <alpine.DEB.2.00.1202271636230.6435@router.home> <alpine.DEB.2.00.1202281329190.25590@router.home>
 <20120229123120.127e21fd.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 29 Feb 2012, Andrew Morton wrote:

> What was the user-visible impact of the bug?

THis was an oops reported by Dave Hansen after he inserted some loops in
the code to trigger a race condition.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
