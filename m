Content-Type: text/plain;
  charset="iso-8859-1"
From: Daniel Phillips <phillips@arcor.de>
Subject: Re: 2.4.19 Vs 2.4.19-rmap14a with anonymous mmaped memory
Date: Thu, 29 Aug 2002 21:34:47 +0200
References: <Pine.LNX.4.44.0208261525570.31523-100000@skynet>
In-Reply-To: <Pine.LNX.4.44.0208261525570.31523-100000@skynet>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <E17kV44-00035H-00@starship>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Monday 26 August 2002 17:13, Mel Gorman wrote:
> On Mon, 26 Aug 2002, Daniel Phillips wrote:
> 
> > Could you please provide pseudocode, to specify these reference patterns
> > more precisely?
> >
> 
> Rather than providing pseudo code, here is a link to the actual function
> that generates the smooth_sin references
> 
> http://www.csn.ul.ie/~mel/vmr/smooth_sin.html
> 
> It is really crude and written to generate any type of data until I
> found the time to generate more realistic data which is a project in
> itself. Anyone who wants to generate better data only has to edit the
> References.pm file.
> 
> It takes there inputs
> 
> references - number of references to generate
> range - the size in pages of the region to reference
> output - the output filename
> 
> the function has three parts
> 
> part 1: Plot a sin wave so that the sum of all the integer values of each
> 	part of it would generate enough references to satisify at least
> 	half of the requessted number
> part 2: Starting at the beginning of the range, reference each page in a
>         linear pattern until all the required references are generated
> part 3: Dump all references to disk
> 
> now that I think of it, it would have made more sense to begin with the
> linear reference pattern and then generate the sin curve but seeing as
> this pattern is nothing resembling real life, I didn't worry about it too
> much. It is probably something I should change as it would illustrate
> better what pages are kept in memory.

The perl script that writes tables isn't too informative without knowing
how the tables are used.  Pseudocode that says exactly what your final
reference pattern is would be a lot more useful.  Just leave out the part
about generating the tables and express it as if you were computing the
distribution at the same time as generating the references, unless it's
really impossible to do that.  I don't think it's impossible to do that
in this case.

It would also be useful to state what you define as a reference.  A user
space program read-accesses a single byte from some address?

-- 
Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
