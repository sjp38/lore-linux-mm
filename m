Received: from atlas.infra.CARNet.hr (zcalusic@atlas.infra.CARNet.hr [161.53.160.131])
	by kvack.org (8.8.7/8.8.7) with ESMTP id NAA27928
	for <linux-mm@kvack.org>; Fri, 13 Mar 1998 13:34:47 -0500
Subject: Re: a name for mmscan
References: <199803131448.PAA25367@boole.suse.de>
Reply-To: Zlatko.Calusic@CARNet.hr
From: Zlatko Calusic <Zlatko.Calusic@CARNet.hr>
Date: 13 Mar 1998 19:34:35 +0100
In-Reply-To: "Dr. Werner Fink"'s message of "Fri, 13 Mar 1998 15:48:13 +0100"
Message-ID: <873egmo2x0.fsf@atlas.infra.CARNet.hr>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

"Dr. Werner Fink" <werner@suse.de> writes:

> > 
> > Hi,
> > 
> > As Ben didn't yet have a suitable name for mmscan, I
> > think we should go with the semi-standard of:
> > vmpager (or kpager, to follow the linux way)
> 
> kpager would be my vote :-)
> 
> 
>                Werner
> 

I like that 'd' at the end of the daemon processes:

(kflushd)
       ^
(kswapd)
      ^

Then again, kpaged sounds slightly odd...

Any other ideas?
-- 
Posted by Zlatko Calusic           E-mail: <Zlatko.Calusic@CARNet.hr>
---------------------------------------------------------------------
      Always forgive your enemies, nothing annoys them so much.
