Reply-To: Gerrit Huizenga <gh@us.ibm.com>
From: Gerrit Huizenga <gh@us.ibm.com>
Subject: LTP memory tests (fwd)
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="----- =_aaaaaaaaaa0"
Content-ID: <22123.1026423138.0@us.ibm.com>
Date: Thu, 11 Jul 2002 14:32:18 -0700
Message-Id: <E17SlXu-0005kt-00@w-gerrit2>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@zip.com.au>, William Lee Irwin III <wli@holomorphy.com>, Rik van Riel <riel@conectiva.com.br>, Dave McCracken <dmccr@us.ibm.com>, Paul Larson <plars@austin.ibm.com>
List-ID: <linux-mm.kvack.org>

------- =_aaaaaaaaaa0
Content-Type: text/plain; charset="us-ascii"
Content-ID: <22123.1026423138.1@us.ibm.com>

The Linux Test project has some tests for VM.  I'm not sure
that all of them are enabled by a default run.  I'd recommend
installing the LTP (ltp.sourceforge.net) and running it as a
minimal regression suite if you haven't done so already.  It
is generally pretty quick and you could probably set up a run
list to focus on VM changes that would run much more quickly.

If you have some specific modifications, e.g.:

	From: Andrew Morton <akpm@zip.com.au>

	The problem is the access pattern.  It shouldn't be
	random-uniform.  But what should it be?  random-gaussian?

	So: map a large file, access it random-gaussian.  malloc
	some memory, access it random-gaussian.  Apply eviction
	pressure. Measure throughput.  Optimise throughput.

	Does this not capture what the VM is supposed to do?

...or enhancments to the current tests that would make them more
useful, yell.

Paul's team typically focuses on functional tests rather than
performance tests.  However, it may be possible to make a set
of deterministic tests that may also be useful for doing some
first level performance comparisons if written correctly.  E.g.
random distributions with a settable initial seed.

gerrit


------- =_aaaaaaaaaa0
Content-Type: message/rfc822
Content-ID: <22123.1026423138.2@us.ibm.com>
Content-Description: forwarded message



------- =_aaaaaaaaaa0--
