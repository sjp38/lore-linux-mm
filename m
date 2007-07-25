Date: Wed, 25 Jul 2007 10:15:41 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: -mm merge plans for 2.6.23
Message-ID: <20070725081541.GA10005@elte.hu>
References: <46A6CC56.6040307@yahoo.com.au> <46A6D7D2.4050708@gmail.com> <1185341449.7105.53.camel@perkele> <46A6E1A1.4010508@yahoo.com.au> <Pine.LNX.4.64.0707242252250.2229@asgard.lang.hm> <46A6E80B.6030704@yahoo.com.au> <Pine.LNX.4.64.0707242316410.2229@asgard.lang.hm> <46A6FAD8.6050107@yahoo.com.au> <20070725074931.GA5125@elte.hu> <46A70299.50809@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <46A70299.50809@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: david@lang.hm, Eric St-Laurent <ericstl34@sympatico.ca>, Rene Herman <rene.herman@gmail.com>, Ray Lee <ray-lk@madrabbit.org>, Jesper Juhl <jesper.juhl@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, ck list <ck@vds.kolivas.org>, Paul Jackson <pj@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

* Nick Piggin <nickpiggin@yahoo.com.au> wrote:

> > > And yet despite my repeated pleas, none of those people has yet 
> > > spent a bit of time with me to help analyse what is happening.
> >
> > btw., it might help to give specific, precise instructions about 
> > what people should do to help you analyze this problem.
> 
> Ray has been the first one to offer (thank you), and yes I have asked 
> him for precise details of info to collect to hopefully work out what 
> is happening with his first problem.

do you mean this paragraph:

| I guess /proc/meminfo, /proc/zoneinfo, /proc/vmstat, /proc/slabinfo 
| before and after the updatedb run with the latest kernel would be a 
| first step. top and vmstat output during the run wouldn't hurt either.

correct? Does "latest kernel" mean v2.6.22.1, or does it have to be 
v2.6.23-rc1? I guess v2.6.22.1 would be fine as this is a VM problem, 
not a scheduling problem.

the following script will gather all the above information for a 10 
seconds interval:

  http://people.redhat.com/mingo/cfs-scheduler/tools/cfs-debug-info.sh

Ray, please run this script before the updatedb run, once during the 
updatedb run and once after the updatedb run, and send Nick the 3 files 
it creates. (feel free to Cc: me too)

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
