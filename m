Subject: Re: More info: 2.1.108 page cache performance on low memory
References: <Pine.LNX.3.95.980723110802.5181A-100000@as200.spellcast.com>
Reply-To: Zlatko.Calusic@CARNet.hr
From: Zlatko Calusic <Zlatko.Calusic@CARNet.hr>
Date: 23 Jul 1998 17:25:41 +0200
In-Reply-To: "Benjamin C.R. LaHaise"'s message of "Thu, 23 Jul 1998 11:17:54 -0400 (EDT)"
Message-ID: <87vhooio7e.fsf@atlas.CARNet.hr>
Sender: owner-linux-mm@kvack.org
To: "Benjamin C.R. LaHaise" <blah@kvack.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

"Benjamin C.R. LaHaise" <blah@kvack.org> writes:

> On 23 Jul 1998, Zlatko Calusic wrote:
> 
> > I was very carefull to do exactly the same sequence in both tests!
> > I think it is obvious from the first line of those vmstat reports.
> > 
> > Anything I forgot to test? :)
> 
> Yeap! ;-)  Could you try Werner Fink's lowmem.patch -- it changes the
> MAX_PAGE_AGE mechanism to have a dynamic upper limit which is lower on
> systems with less memory...  That should have a similar effect to the
> multiple invocations of age_page that you tried.
> 

Not really! :)

I'm trying and trying, but every time...

While trying to retrieve the URL: http://riemann.suse.de/~werner/patches/ 

The following error was encountered: 

      ERROR 308 -- Cannot connect to the original site 

This means that: 

    The remote site may be down.


Could you please send me a copy, since I don't know for how long host
will be down?

Regards,
-- 
Posted by Zlatko Calusic           E-mail: <Zlatko.Calusic@CARNet.hr>
---------------------------------------------------------------------
		       Don't mess with Murphy.
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
