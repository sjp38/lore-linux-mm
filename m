Date: Mon, 29 Nov 2004 22:42:12 -0200
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Automated performance testing system was Re: Text form for STP tests
Message-ID: <20041130004212.GB2310@dmt.cyclades>
References: <20041125093135.GA15650@logos.cnet> <200411282017.iASKH2F05015@mail.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200411282017.iASKH2F05015@mail.osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Cliff White <cliffw@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Linux-MM fellows,

I've been talking to Cliff about the need for a set of benchmarks,
covering as many different workloads as possible, for developers to have a 
better notion of impact on performance changes. 

Usually when one does a change which affects performance, he/she runs one 
or two benchmarks with a limited amount of hardware configurations.
This is a very painful, boring and time consuming process, which can 
result in misinterpretation and/or limited understading of the results 
of such changes.

It is important to automate such process, with a set of benchmarks 
covering as wide as possible range of workloads, running on common 
and most used hardware variations.

OSDL's STP provides the base framework for this.

Cliff mentioned an internal tool they are developing for this purpose, 
based on XML-like configuration files. 

I have suggested him a set of benchmarks (available on STP right now, 
we want to add other benchmarks there whenever necessary) and a set of 
CPU/memory variations.

Quoting myself:

"here is a list of a wide enough 
group of performance tests, for a start:

bonnie++
reaim (default, new_fserver, shared)
dbench_long
kernbench
tiobench

Each of these running one the following combinations:

1CPU, 2CPU, 4CPU, 8CPU (4 variants).

total memory, half memory, a quarter of total memory (3 variants).

Thats 12 results for each benchmark."

Obviously this set of benchmarks is limited (an example set), they are 
relatively similar, but it is a start. 
In the future we ough to have several sets of benchmarks.

We also need a way to easily visualize such results, which is the next
step of the project. x,y graphics are the best way for most tests 
I believe.

Construction of such automated testing infrastructure will improve our 
capabilities giving better notion of impact while decreasing 
wasted time and wasted efforts.

Of course this needs to be a collaborative effort, I expect others
interested to help, comment and get involved.

Follows my private discussion with Cliff up till now, for reference.

On Sun, Nov 28, 2004 at 12:17:02PM -0800, Cliff White wrote:
> > 
> > Hi Cliff,
> > 
> > On Wed, Nov 24, 2004 at 10:22:57AM -0800, Cliff White wrote:
> > > 
> > > Marcelo, we are working on a better version of 
> > > this as I mentioned, plus a command line tool.
> > 
> > Great :)
> > 
> > > The current file is almost XML, and some
> > > of the data is internal to our database. If you
> > > can indicate what tests you want to run on specific
> > > sizes of machines,  we can supply all the numbers. 
> > > 
> > > It the XML is too much, just send me a list of what you
> > > want, and we can go from there.
> > 
> > That looks fine to me - here is a list of a wide enough 
> > group of performance tests, for a start:
> > 
> > bonnie++
> > reaim (default, new_fserver, shared)
> > dbench_long
> > kernbench
> > tiobench
> > 
> > Each of these running one the following combinations:
> > 
> > 1CPU, 2CPU, 4CPU, 8CPU (4 variants).
> > 
> > total memory, half memory, a quarter of total memory (3 variants).
> > 
> > Thats 12 results for each benchmark. 
> 
> I can get this setup monday, ( long weekend ) 
> > 
> > We need to make those results visually easy to read/interpret, 
> > but thats another story which can be done independantly.
> > A x,y graph is the easier way to visualize - thats the next step.
> 
> Great, appreciate any input on this. 
> 
> > 
> > > We have an automated tool that does a string match against
> > > kernel.org patch names, if you have a specific regexp, we
> > > can tie an automatic test submit to that. 
> > > 
> > > The text file just specifies test details, kernel patch info
> > > is supplied in a separate step, so one text file can
> > > be re-used.
> > 
> > OK - great. We want to run the testgroup on baseline kernel 
> > and on baseline+modification, of course.
> > 
> > Can we move this discussion to linux-mm? I'm sure others are interested
> > as well.
> 
> Sure, would you start a thread? I'm on that list already.
> cliffw
> 
> > 
> > Many thanks, this will certainly improve out performance testing capabilities.
> > 
> > > ------------Current-------------------
> > > <config >
> > >     <stp2-000 host="77">
> > >         <aio-stress testID="82">
> > >             <distro>4</distro>
> > >             <run>
> > >                 <lilo>profile=2</lilo>
> > >                 <opt pID="-F" val="1" />
> > >                 <opt pID="-s" val="4g" />
> > >             </run>
> > >         </aio-stress>
> > >     </stp2-000>
> > > </config>
> > > ----------------------------------
> > > 
> > > We've changed the format some, but the tools to use
> > > it are still being fixed up. New format (so far)
> > > will look like this: ( the 'test name' and 'host name' bits allow
> > > for multiple runs of the same test/host )
> > > 
> > > --------------------------------
> > > 
> > > <config>
> > >   <host name="cpu1" id="14">
> > >     <test name="dummy_test" id="82">
> > >       <distro id="4" />
> > >       <run>
> > >         <lilo>profile=2</lilo>
> > >         <param name="-o">25</param>
> > >         <param name="-z">foobar</param>
> > >       </run>
> > >       <run>
> > >         <lilo>profile=2</lilo>
> > >         <param name="-o">25</param>
> > >         <param name="-z">foobar</param>
> > >       </run>
> > >     </test>
> > >   </host>
> > >  <host name="cpu2" id="15">
> > >     <test name="dummy_test" id="82">
> > >     <distro id="4" />
> > >       <run>
> > >         <lilo>profile=2</lilo>
> > >         <param name="-o">25</param>
> > >         <param name="-z">foobar</param>
> > >       </run>
> > >     </test>
> > >   </host>
> > > </config>
> > > ----------------------------------
> > > 
> > > cliffw
> > 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
