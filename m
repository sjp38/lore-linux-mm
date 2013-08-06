Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id A6BF16B0038
	for <linux-mm@kvack.org>; Tue,  6 Aug 2013 07:38:03 -0400 (EDT)
Received: from /spool/local
	by e23smtp05.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Tue, 6 Aug 2013 21:31:08 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 3D9093578050
	for <linux-mm@kvack.org>; Tue,  6 Aug 2013 21:37:56 +1000 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r76BM2Fj4653452
	for <linux-mm@kvack.org>; Tue, 6 Aug 2013 21:22:07 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r76Bboto021906
	for <linux-mm@kvack.org>; Tue, 6 Aug 2013 21:37:50 +1000
Date: Tue, 6 Aug 2013 19:37:49 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: Testing results of zswap
Message-ID: <20130806113749.GA14314@hacker.(null)>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <CAA_GA1fiEJYxqAZ1c0BneuftB5g8d+2_mYBj=4iE=1EcYaTx7w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="5vNYLRcllDrimb99"
Content-Disposition: inline
In-Reply-To: <CAA_GA1fiEJYxqAZ1c0BneuftB5g8d+2_mYBj=4iE=1EcYaTx7w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: Linux-MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>, bob.liu@oracle.com, Mel Gorman <mgorman@suse.de>


--5vNYLRcllDrimb99
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Thu, Jun 27, 2013 at 10:03:52AM +0800, Bob Liu wrote:
>Hi All,
>
>These days I have been testing zswap.
>I found that the total ram size of my testing machine effected the
>testing result.
>
>If I limit  RAM size to 2G using "mem=", the performance of zswap is
>very disappointing,
>But if I use larger RAM size such as 8G, the performance is much better.
>Even with RAM size 8G, zswap will slow down the speed of parallelio.
>
>I run the testing(mmtest-0.10 with
>config-global-dhp__parallelio-memcachetest) after the default
>distribution booted every time.
>

Hi Bob,

I see improvement against v3.11-rc1 w/ 2G memory.


--5vNYLRcllDrimb99
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=test

                                          nozswap2                      zswap2
                                         nozswap2G                     zswap2G
Ops memcachetest-0M             12731.00 (  0.00%)          11561.00 ( -9.19%)
Ops memcachetest-201M           11373.00 (  0.00%)          11084.00 ( -2.54%)
Ops memcachetest-672M           11350.00 (  0.00%)          10910.00 ( -3.88%)
Ops memcachetest-1142M          11057.00 (  0.00%)          11060.00 (  0.03%)
Ops io-duration-0M                  0.00 (  0.00%)              0.00 (  0.00%)
Ops io-duration-201M                4.00 (  0.00%)              5.00 (-25.00%)
Ops io-duration-672M                9.00 (  0.00%)              7.00 ( 22.22%)
Ops io-duration-1142M              11.00 (  0.00%)             13.00 (-18.18%)
Ops swaptotal-0M                  451.00 (  0.00%)          26208.00 (-5711.09%)
Ops swaptotal-201M             158775.00 (  0.00%)          37548.00 ( 76.35%)
Ops swaptotal-672M             139599.00 (  0.00%)          42514.00 ( 69.55%)
Ops swaptotal-1142M            137789.00 (  0.00%)          34580.00 ( 74.90%)
Ops swapin-0M                     451.00 (  0.00%)          11830.00 (-2523.06%)
Ops swapin-201M                 29082.00 (  0.00%)          16169.00 ( 44.40%)
Ops swapin-672M                 26611.00 (  0.00%)          19574.00 ( 26.44%)
Ops swapin-1142M                27238.00 (  0.00%)          15625.00 ( 42.64%)
Ops minorfaults-0M             557891.00 (  0.00%)         575357.00 ( -3.13%)
Ops minorfaults-201M           743922.00 (  0.00%)         595238.00 ( 19.99%)
Ops minorfaults-672M           727870.00 (  0.00%)         653777.00 ( 10.18%)
Ops minorfaults-1142M          722946.00 (  0.00%)         595093.00 ( 17.68%)
Ops majorfaults-0M                116.00 (  0.00%)           4053.00 (-3393.97%)
Ops majorfaults-201M             4251.00 (  0.00%)           4412.00 ( -3.79%)
Ops majorfaults-672M             3854.00 (  0.00%)           4971.00 (-28.98%)
Ops majorfaults-1142M            3910.00 (  0.00%)           4033.00 ( -3.15%)


--5vNYLRcllDrimb99--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
