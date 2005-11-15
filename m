Date: Mon, 14 Nov 2005 22:28:46 -0500 (EST)
From: Rik van Riel <riel@redhat.com>
Subject: Re: why its dead now?
In-Reply-To: <f68e01850511131035l3f0530aft6076f156d4f62171@mail.gmail.com>
Message-ID: <Pine.LNX.4.63.0511142227540.15035@cuia.boston.redhat.com>
References: <f68e01850511131035l3f0530aft6076f156d4f62171@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nitin Gupta <nitingupta.mail@gmail.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 14 Nov 2005, Nitin Gupta wrote:

> Are there any serious drawbacks to this?

Compressed caching may be hard to tune right for some workloads.
I cannot see any other drawbacks - certainly nothing that should
keep you from working on it...

> Do you think it will be of any use if ported to 2.6 kernel?

It has the potential to be very useful.

-- 
All Rights Reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
