Date: Thu, 23 Jul 1998 11:17:54 -0400 (EDT)
From: "Benjamin C.R. LaHaise" <blah@kvack.org>
Subject: Re: More info: 2.1.108 page cache performance on low memory
In-Reply-To: <87btqg1u9j.fsf@atlas.CARNet.hr>
Message-ID: <Pine.LNX.3.95.980723110802.5181A-100000@as200.spellcast.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Zlatko Calusic <Zlatko.Calusic@CARNet.hr>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, "Eric W. Biederman" <ebiederm+eric@npwt.net>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 23 Jul 1998, Zlatko Calusic wrote:

> I was very carefull to do exactly the same sequence in both tests!
> I think it is obvious from the first line of those vmstat reports.
> 
> Anything I forgot to test? :)

Yeap! ;-)  Could you try Werner Fink's lowmem.patch -- it changes the
MAX_PAGE_AGE mechanism to have a dynamic upper limit which is lower on
systems with less memory...  That should have a similar effect to the
multiple invocations of age_page that you tried.

		-ben

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
