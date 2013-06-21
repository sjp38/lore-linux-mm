Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 089A96B0037
	for <linux-mm@kvack.org>; Fri, 21 Jun 2013 11:21:59 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <253b3e7e-e65e-407a-adfe-f3fdd9a1909e@default>
Date: Fri, 21 Jun 2013 08:20:34 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCHv13 3/4] zswap: add to mm/
References: <1370291585-26102-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <1370291585-26102-4-git-send-email-sjenning@linux.vnet.ibm.com>
 <CAA_GA1eWFYDxp3gEdWzajVP4jMpmJbt=oWBZYqZEQjndU=s_Qg@mail.gmail.com>
 <20130620023750.GA1194@cerebellum>
 <CAA_GA1c8cH1fu9jHk8evKZvK-gpQ+c8NEp5=_jDLKPcMbG_ufA@mail.gmail.com>
 <20130620142328.GA9461@cerebellum>
 <CAA_GA1eoD6Q6uYjQyJUhSuusNZn7TvekF1-EQLATSywatCHk3g@mail.gmail.com>
In-Reply-To: <CAA_GA1eoD6Q6uYjQyJUhSuusNZn7TvekF1-EQLATSywatCHk3g@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Wilk <konrad.wilk@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave@sr71.net>, Joe Perches <joe@perches.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, Hugh Dickens <hughd@google.com>, Paul Mackerras <paulus@samba.org>, Linux-MM <linux-mm@kvack.org>, Linux-Kernel <linux-kernel@vger.kernel.org>, devel@driverdev.osuosl.org

> From: Bob Liu [mailto:lliubbo@gmail.com]
 Subject: Re: [PATCHv13 3/4] zswap: add to mm/
>=20
> On Thu, Jun 20, 2013 at 10:23 PM, Seth Jennings
> <sjenning@linux.vnet.ibm.com> wrote:
> > On Thu, Jun 20, 2013 at 05:42:04PM +0800, Bob Liu wrote:
> >> > Just made a mmtests run of my own and got very different results:
> >> >
> >>
> >> It's strange, I'll update to rc6 and try again.
> >> By the way, are you using 824 hardware compressor instead of lzo?
> >
> > My results where using lzo software compression.
> >
>=20
> Thanks, and today I used another machine to test zswap.
> The total ram size of that machine is around 4G.
> This time the result is better:
>                                                rc6                       =
  rc6
>                                              zswap                       =
 base
> Ops memcachetest-0M             14619.00 (  0.00%)          15602.00 (  6=
.72%)
> Ops memcachetest-435M           14727.00 (  0.00%)          15860.00 (  7=
.69%)
> Ops memcachetest-944M           12452.00 (  0.00%)          11812.00 ( -5=
.14%)
> Ops memcachetest-1452M          12183.00 (  0.00%)           9829.00 (-19=
.32%)
> Ops memcachetest-1961M          11953.00 (  0.00%)           9337.00 (-21=
.89%)
> Ops memcachetest-2469M          11201.00 (  0.00%)           7509.00 (-32=
.96%)
> Ops memcachetest-2978M           9738.00 (  0.00%)           5981.00 (-38=
.58%)
> Ops io-duration-0M                  0.00 (  0.00%)              0.00 (  0=
.00%)
> Ops io-duration-435M               10.00 (  0.00%)              6.00 ( 40=
.00%)
> Ops io-duration-944M               19.00 (  0.00%)             19.00 (  0=
.00%)
> Ops io-duration-1452M              31.00 (  0.00%)             26.00 ( 16=
.13%)
> Ops io-duration-1961M              40.00 (  0.00%)             35.00 ( 12=
.50%)
> Ops io-duration-2469M              45.00 (  0.00%)             43.00 (  4=
.44%)
> Ops io-duration-2978M              58.00 (  0.00%)             53.00 (  8=
.62%)
> Ops swaptotal-0M                56711.00 (  0.00%)              8.00 ( 99=
.99%)
> Ops swaptotal-435M              19218.00 (  0.00%)           2101.00 ( 89=
.07%)
> Ops swaptotal-944M              53233.00 (  0.00%)          98055.00 (-84=
.20%)
> Ops swaptotal-1452M             52064.00 (  0.00%)         145624.00 (-17=
9.70%)
> Ops swaptotal-1961M             54960.00 (  0.00%)         153907.00 (-18=
0.03%)
> Ops swaptotal-2469M             57485.00 (  0.00%)         176340.00 (-20=
6.76%)
> Ops swaptotal-2978M             77704.00 (  0.00%)         182996.00 (-13=
5.50%)
> Ops swapin-0M                   24834.00 (  0.00%)              8.00 ( 99=
.97%)
> Ops swapin-435M                  9038.00 (  0.00%)              0.00 (  0=
.00%)
> Ops swapin-944M                 26230.00 (  0.00%)          42953.00 (-63=
.76%)
> Ops swapin-1452M                25766.00 (  0.00%)          68440.00 (-16=
5.62%)
> Ops swapin-1961M                27258.00 (  0.00%)          68129.00 (-14=
9.94%)
> Ops swapin-2469M                28508.00 (  0.00%)          82234.00 (-18=
8.46%)
> Ops swapin-2978M                37970.00 (  0.00%)          89280.00 (-13=
5.13%)
> Ops minorfaults-0M            1460163.00 (  0.00%)         927966.00 ( 36=
.45%)
> Ops minorfaults-435M           954058.00 (  0.00%)         936182.00 (  1=
.87%)
> Ops minorfaults-944M           972818.00 (  0.00%)        1005956.00 ( -3=
.41%)
> Ops minorfaults-1452M          966597.00 (  0.00%)        1035465.00 ( -7=
.12%)
> Ops minorfaults-1961M          976158.00 (  0.00%)        1049441.00 ( -7=
.51%)
> Ops minorfaults-2469M          967815.00 (  0.00%)        1051752.00 ( -8=
.67%)
> Ops minorfaults-2978M          988712.00 (  0.00%)        1034615.00 ( -4=
.64%)
> Ops majorfaults-0M               5899.00 (  0.00%)              9.00 ( 99=
.85%)
> Ops majorfaults-435M             2684.00 (  0.00%)             67.00 ( 97=
.50%)
> Ops majorfaults-944M             4380.00 (  0.00%)           5790.00 (-32=
.19%)
> Ops majorfaults-1452M            4161.00 (  0.00%)           9222.00 (-12=
1.63%)
> Ops majorfaults-1961M            4435.00 (  0.00%)           8800.00 (-98=
.42%)
> Ops majorfaults-2469M            4555.00 (  0.00%)          10541.00 (-13=
1.42%)
> Ops majorfaults-2978M            6182.00 (  0.00%)          11618.00 (-87=
.93%)
>=20
>=20
> But the performance of the first machine I used whose total ram size
> is 2G is still bad.
> I need more time to summarize those testing results.
>=20
> Maybe you can also have a try with lower total ram size.
>=20
> --
> Regards,
> --Bob


A very important factor that you are not considering and
that might account for your different results is the
"initial conditions".  For example, I always ran my benchmarks
after a default-configured EL6 boot, which launches many services
at boot time, each of which creates many anonymous pages,
and these "service anonymous pages" are often the pages
that are selected by LRU for swapping, and compressed by zcache/zswap.
Someone else may run the benchmarks on a minimally-configured
embedded system, and someone else on a single-user system
with no services running at all.  A single-user system with
no services is often best for reproducing benchmark results but
may not be at all representative of the real world.

At a minimum, it would be good to always record "Active(anon)"
and "Inactive(anon)" in addition to the amount of physical
RAM in the system.  (Note, in /proc/meminfo on my system,
the sum of these don't add up to "AnonPages"... I'm not sure
why.)

And of course, even if the number of anonymous pages is
the same, the _contents_ of those pages may be very different,
which will affect zcache/zswap density which may have
a large impact on benchmark results.

Thanks,
Dan (T-minus two weeks and counting)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
