Subject: Re: pre2 swap_out() changes
References: <Pine.LNX.4.21.0101141206130.12327-100000@freak.distro.conectiva>
Reply-To: zlatko@iskon.hr
From: Zlatko Calusic <zlatko@iskon.hr>
Date: 14 Jan 2001 17:15:39 +0100
In-Reply-To: Marcelo Tosatti's message of "Sun, 14 Jan 2001 12:13:05 -0200 (BRST)"
Message-ID: <871yu6w1n8.fsf@atlas.iskon.hr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@conectiva.com.br>
Cc: Ed Tomlinson <tomlins@cam.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Marcelo Tosatti <marcelo@conectiva.com.br> writes:

> On Sun, 14 Jan 2001, Ed Tomlinson wrote:
> 
> > Hi,
> > 
> > A couple of observations on the pre2/pre3 vm.  It seems to start swapping out 
> > very quicky but this does not seem to hurt.  Once there is memory preasure 
> > and swapin starts cpu utilization drops thru the roof - kernel compiles are 
> > only able to drive the system at 10-20% (UP instead of 95-100%).  Once the 
> > system stops swapping (in) there are some side effects.  Closing windows 
> > in X becomes jerky (ie you see blocks get cleared and refreshed).  If little 
> > or no swapping has occured X is much faster.
> > 
> > With the patch marcelo posted last night things change.  Now It can use cpu 
> > when swapping.  It does seem to start swaping (in and out) faster but the 
> > system remains more interactive than above.  I still see the X effect though.
> > 
> > Over all I think 2.4.0+marcelo's first patch(es) was fastest.
> 

My opinion exactly, Ed! Don't let me copy/paste all of your comment as
mine just beacuse your English is better. :)

> There is still a critical thing to be fixed which is the swapout selection
> path (which is probably what is causing your problem in X)
> 

Yes, while swapout code in pre3 is much cleaner and nicer to see, but
it has problems with deciding what to swap out, and streaming it all
well. Glad we agree. Will check your new patch now, to see if it helps.
-- 
Zlatko
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
