Subject: Re: 2.4 / 2.5 VM plans
References: <Pine.LNX.4.21.0006242357020.15823-100000@duckman.distro.conectiva>
	<m2bt0l4s39.fsf@boreas.southchinaseas>
From: "Juan J. Quintela" <quintela@fi.udc.es>
In-Reply-To: vii@penguinpowered.com's message of "28 Jun 2000 18:45:46 +0100"
Date: 28 Jun 2000 23:04:45 +0200
Message-ID: <yttog4lwm8i.fsf@serpe.mitica>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: vii@penguinpowered.com
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>>>> "vii" == vii  <vii@penguinpowered.com> writes:

Hi

>> 3) separate page replacement (page aging) and page flushing,

vii> Definitely!

I have done part of this work with my write deferred swap (I will port
it to test3 ASAP).  The deferred swap write also helps.  It is related
with your question about removing swap_out function, it is related
with the scanning and the several lists setup.


vii> BTW, Is there any timescale for integrating page coloring? Someone
vii> produced a patch somewhere (IIRC specifically for the alpha, sorry to
vii> be so vague).

There was a page colouring patch frem somone at DEC^WCompaq, and
another one from David Miller.  The one from Compaq appeared to have
some problems with some workloads (see the comments from Dave Miller,
I think in this list).  I haven't seen the David one, I can't comment
on that.  But I suppose that the integration will be a 2.5 thing
(Wild, wild guess).

Later, Juan.

-- 
In theory, practice and theory are the same, but in practice they 
are different -- Larry McVoy
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
