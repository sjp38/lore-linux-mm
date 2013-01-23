Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id 11A8C6B0008
	for <linux-mm@kvack.org>; Wed, 23 Jan 2013 16:55:58 -0500 (EST)
Message-ID: <1358978156.21576.129.camel@gandalf.local.home>
Subject: Re: FIX [0/2] Slub hot path fixes
From: Steven Rostedt <rostedt@goodmis.org>
Date: Wed, 23 Jan 2013 16:55:56 -0500
In-Reply-To: <0000013c695fbbe8-6a7f750f-4647-40b8-9ab3-f4fa5af8c382-000000@email.amazonses.com>
References: 
	<0000013c695fbbe8-6a7f750f-4647-40b8-9ab3-f4fa5af8c382-000000@email.amazonses.com>
Content-Type: text/plain; charset="ISO-8859-15"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, RT <linux-rt-users@vger.kernel.org>, Clark Williams <clark@redhat.com>, John Kacur <jkacur@gmail.com>, "Luis Claudio R. Goncalves" <lgoncalv@redhat.com>, Joonsoo Kim <js1304@gmail.com>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, elezegarcia@gmail.com

On Wed, 2013-01-23 at 21:45 +0000, Christoph Lameter wrote:
> These are patches to fix up the issues brought up by Steven Rostedt.
> 
> I hoped to avoid the preempt disable for the tid retrieval but there is
> no per cpu atomic way to get a value from the per cpu area and also retrieve
> the pointer used in that operation. The pointer is necessary to fetch the
> related data from the per cpu structure. Without that we
> run into more issues with page pointer checks that can cause
> freelist corruption in slab_free().

Thanks for looking into this. Your can add my "Reported-by" tags to the
patches. Just because I like labels ;-)

-- Steve


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
