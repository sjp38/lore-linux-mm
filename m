From: "Peter Teoh" <htmldeveloper@gmail.com>
Subject: Re: RFC: swaptrace tool
Date: Wed, 2 Apr 2008 15:52:23 +0800
Message-ID: <804dabb00804020052v391622adm4db85c4837e2ed87@mail.gmail.com>
References: <20080401212542.1717.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <f284c33d0804011823w24898158s5b09256c16d45605@mail.gmail.com>
	 <20080402115000.E130.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <f284c33d0804012249vb16325fpb9946487140c5905@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <kernelnewbies-bounce@nl.linux.org>
In-Reply-To: <f284c33d0804012249vb16325fpb9946487140c5905@mail.gmail.com>
Content-Disposition: inline
Sender: kernelnewbies-bounce@nl.linux.org
Errors-to: kernelnewbies-bounce@nl.linux.org
List-help: <mailto:ecartis@nl.linux.org?Subject=help>
List-unsubscribe: <mailto:kernelnewbies-request@nl.linux.org?Subject=unsubscribe>
List-software: Ecartis version 1.0.0
List-subscribe: <mailto:kernelnewbies-request@nl.linux.org?Subject=subscribe>
List-owner: <mailto:ecartis-owner@nl.linux.org>
List-post: <mailto:kernelnewbies@nl.linux.org>
List-archive: <http://mail.nl.linux.org/kernelnewbies/>
To: Mulyadi Santosa <mulyadi.santosa@gmail.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Kernel Newbies <kernelnewbies@nl.linux.org>, linux-mm@kvack.org
List-Id: linux-mm.kvack.org

On Wed, Apr 2, 2008 at 1:49 PM, Mulyadi Santosa
<mulyadi.santosa@gmail.com> wrote:
> Hi all
>
>  On Wed, Apr 2, 2008 at 9:58 AM, KOSAKI Motohiro
>
> <kosaki.motohiro@jp.fujitsu.com> wrote:
>
> > Hi
>  >
>  >
>  >  > >  hmm,
>  >  > >  I can't find it from mailing list log.
>  >  > >  Could you recall subject of that patch?
>  >  >
>  >  > here is the URL http://lkml.org/lkml/2006/8/4/77
>  >
>  >  Oh! thanks.
>  >  but, this patch only get per process # of swap pages.
>
>  yeah, I was newbie and still newbie until this very moment :)
>
>
>  >  and the following patch is merged -mm before a while.
>  >  http://marc.info/?l=linux-kernel&m=120654533828554&w=2
>
>  arghhh, peterz beat me again! :D


Did he???

>
>
>  >  thus, now we have its capability via /proc/pid/smap.
>

For a criticism of smaps:

http://bmaurer.blogspot.com/2006/03/memory-usage-with-smaps.html

and btw....i cannot find any "swp" or "swap" output.   so peterz and
yours are non-overlapping.

-- 
Regards,
Peter Teoh

--
To unsubscribe from this list: send an email with
"unsubscribe kernelnewbies" to ecartis@nl.linux.org
Please read the FAQ at http://kernelnewbies.org/FAQ
