Date: Wed, 14 Feb 2007 15:44:38 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: Use ZVC counters to establish exact size of dirtyable pages
Message-Id: <20070214154438.4a80b403.akpm@linux-foundation.org>
In-Reply-To: <Pine.LNX.4.64.0702141521090.3615@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0702121014500.15560@schroedinger.engr.sgi.com>
	<20070213000411.a6d76e0c.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0702130933001.23798@schroedinger.engr.sgi.com>
	<20070214142432.a7e913fa.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0702141433190.3228@schroedinger.engr.sgi.com>
	<20070214151931.852766f9.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0702141521090.3615@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 14 Feb 2007 15:35:59 -0800 (PST)
Christoph Lameter <clameter@sgi.com> wrote:

> If you want to be safe we can make sure that the number returned is > 0.

Yes, something like that (with a suitable comment) sounds like the suitable way
to avoid these problems.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
