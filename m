Date: Tue, 15 Aug 2000 14:28:33 +0200 (CEST)
From: Mike Galbraith <mikeg@weiden.de>
Subject: Re: [prePATCH] new VM for linux-2.4.0-test4
In-Reply-To: <Pine.LNX.4.21.0008141928370.1599-100000@duckman.distro.conectiva>
Message-ID: <Pine.Linu.4.10.10008151344170.1404-100000@mikeg.weiden.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

On Mon, 14 Aug 2000, Rik van Riel wrote:

> OK, I overlooked one of the bad bad bad mistakes watashi 
> saw .. here is an -incremental- patch to fix the last
> possible source of memory leakage...

Hi Rik,

I put vm6 and this bugfix into test7-pre4.ikd, checked for leakage
with memleak.. found absolutely nothing.

I then disabled ikd and did some light performance comparison using
my favorite generic test (make -j30 bzImage [1]).  Tests conducted in
identical as possible manner compiling the same tree.

test7-pre4.vm6
real    9m42.191s
user    6m31.440s
sys     0m34.820s

test7-pre4.stock
real    13m38.449s
user    6m31.000s
sys     0m38.250s

ac22-classzone+
real    7m48.594s
user    6m30.750s
sys     0m31.860s

Definite improvement over stock vm, but still not as good at keeping
30 hungry tasks fed as classzone (on my 128mb single PIII box).  All
numbers fully repeatable +- normal test jitter.

Streaming I/O seems to be suffering a bit, but I didn't measure enough
to be 100% sure of that.

	-Mike

1.  Think of it as a simulation of thirty students on a small
    classroom server in a 3rd world nation (ala Brooklyn N.Y.;)
    all compiling their individual bits of a group project.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
