Date: Thu, 26 Sep 2002 09:46:27 -0400 (EDT)
From: Zwane Mwaikambo <zwane@linuxpower.ca>
Subject: Re: 2.5.38-mm3
In-Reply-To: <20020926133919.GQ3530@holomorphy.com>
Message-ID: <Pine.LNX.4.44.0209260944300.1819-100000@montezuma.mastecende.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Dipankar Sarma <dipankar@in.ibm.com>, Andrew Morton <akpm@digeo.com>, lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 26 Sep 2002, William Lee Irwin III wrote:

> On Thu, Sep 26, 2002 at 09:29:36AM -0400, Zwane Mwaikambo wrote:
> > I can affirmative that;
> > 6124639 total                                      4.1414
> > 4883005 default_idle                             101729.2708
> > 380218 ata_input_data                           1697.4018
> > 242647 ata_output_data                          1083.2455
> >  35989 do_select                                 60.7922
> >  34931 unix_poll                                218.3187
> >  33561 schedule                                  52.4391
> >  29823 do_softirq                               155.3281
> >  27021 fget                                     422.2031
> >  25270 sock_poll                                526.4583
> 
> Interesting, can you narrow down the poll overheads any? No immediate
> needs (read as: leave your box up, but  watch for it when you can),
> but I'd be interested in knowing if it's fd chunk or poll table setup
> overhead.

Sure, i'm pretty sure i know which application is doing that so i can 
reproduce easily enough.

	Zwane
-- 
function.linuxpower.ca

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
