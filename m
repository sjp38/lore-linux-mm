From: "Peter Teoh" <htmldeveloper@gmail.com>
Subject: Re: RFC: swaptrace tool
Date: Wed, 2 Apr 2008 11:28:49 +0800
Message-ID: <804dabb00804012028j41acca2ya69081bb92c6788d@mail.gmail.com>
References: <20080401212542.1717.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <f284c33d0804011823w24898158s5b09256c16d45605@mail.gmail.com>
	 <20080402115000.E130.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <kernelnewbies-bounce@nl.linux.org>
In-Reply-To: <20080402115000.E130.KOSAKI.MOTOHIRO@jp.fujitsu.com>
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
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Mulyadi Santosa <mulyadi.santosa@gmail.com>, Kernel Newbies <kernelnewbies@nl.linux.org>, linux-mm@kvack.org, Rik van Riel <riel@surriel.com>
List-Id: linux-mm.kvack.org

On Wed, Apr 2, 2008 at 10:58 AM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
> Hi
>
>
>  > >  hmm,
>  > >  I can't find it from mailing list log.
>  > >  Could you recall subject of that patch?
>  >
>  > here is the URL http://lkml.org/lkml/2006/8/4/77
>
>  Oh! thanks.
>  but, this patch only get per process # of swap pages.
>
>  and the following patch is merged -mm before a while.
>  http://marc.info/?l=linux-kernel&m=120654533828554&w=2
>
>  thus, now we have its capability via /proc/pid/smap.
>
>  in my understanding, originally requirement wanted following tuple.
>
>   - destination begin offset / size
>   - source begin offset / size
>   - process/task
>
>

ah...yes...exactly.   but Mulyadi patch is good headstart for me to
focus on - to see how it can be tweaked for extracting out this lean
information.   lean because as compared with blktrace, it is just
focusing on the BOUNDARY of the swapspace being written or read
(whereas blktrace will include the data itself).....every seconds or
every minutes, snapshot of these kind of information will allow us to
see how the swapspace is dynamically being used....and then we can
then design a good page replacement policy or swapspace usage
algorithm.....eg, to maximize the clustering factor when paging.
sort of a simulation tool......

-- 
Regards,
Peter Teoh

--
To unsubscribe from this list: send an email with
"unsubscribe kernelnewbies" to ecartis@nl.linux.org
Please read the FAQ at http://kernelnewbies.org/FAQ
