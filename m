Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id 431F36B007E
	for <linux-mm@kvack.org>; Thu,  8 Mar 2012 17:46:30 -0500 (EST)
Message-ID: <1331246780.11248.451.camel@twins>
Subject: Re: [PATCH] hugetlbfs: lockdep annotate root inode properly
From: Peter Zijlstra <peterz@infradead.org>
Date: Thu, 08 Mar 2012 23:46:20 +0100
In-Reply-To: <1331246669.11248.449.camel@twins>
References: 
	<1331198116-13670-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
	 <20120308130256.c7855cbd.akpm@linux-foundation.org>
	 <20120308214425.GA23916@ZenIV.linux.org.uk>
	 <1331246669.11248.449.camel@twins>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-mm@kvack.org, davej@redhat.com, jboyer@redhat.com, tyhicks@canonical.com, linux-kernel@vger.kernel.org, Mimi Zohar <zohar@linux.vnet.ibm.com>

On Thu, 2012-03-08 at 23:44 +0100, Peter Zijlstra wrote:
> On Thu, 2012-03-08 at 21:44 +0000, Al Viro wrote:
> > I suspect that they right thing would be to have a way to set explicit
> > nesting rules, not tied to speficic call trace.=20
>=20
> See might_lock() / might_lock_read(), these are used to implement
> might_fault(), which is used to annotate paths that could -- but rarely
> do -- fault.

This will of course result in a specific trace, but if you do it early
enough the trace points to your setup function, which can contain a
comment explaining things.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
