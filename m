Date: Fri, 5 Jul 2002 11:22:40 +0530
From: Abhishek Nayani <abhi@kernelnewbies.org>
Subject: Re: Benchmarking Tool
Message-ID: <20020705055240.GA1776@SandStorm.net>
References: <20020703060446.GA2560@SandStorm.net> <Pine.LNX.4.44L.0207041540400.6047-100000@imladris.surriel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44L.0207041540400.6047-100000@imladris.surriel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Thu, 04 Jul 2002, Rik van Riel wrote:
> On Wed, 3 Jul 2002, Abhishek Nayani wrote:
> 
> > the matter. I would like to know what is missing in the current set of
> > tools (lmbench, dbench..) and what is required.
> 
> Most of the current "VM tests" don't seem to have anything
> like a working set.  This basically means that one of the
> central and important parts of the VM - page replacement -
> isn't getting tested AT ALL.
> 
> It might be interesting to have some "working set emulator"
> where a program accesses N out of M MB of total memory a
> lot and the rest a little, where N, M and the ratio between
> the accesses are varied in such a way that the system is
> confronted with various sizes of workload.
> 

	We will start creating a list of variables needing to be
measured and any current solutions/ideas to test them.

	o Working Set
		Useful URLs:
		http://www.cs.inf.ethz.ch/CoPs/ECT/



	Please add to the list.

					Bye,
						Abhi.
	
--------------------------------------------------------------------------------
Those who cannot remember the past are condemned to repeat it - George Santayana
--------------------------------------------------------------------------------
                          Home Page: http://www.abhi.tk
-----BEGIN GEEK CODE BLOCK------------------------------------------------------
GCS d+ s:- a-- C+++ UL P+ L+++ E- W++ N+ o K- w--- O-- M- V- PS PE Y PGP 
t+ 5 X+ R- tv+ b+++ DI+ D G e++ h! !r y- 
------END GEEK CODE BLOCK-------------------------------------------------------
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
