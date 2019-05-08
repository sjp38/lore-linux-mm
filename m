Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	T_DKIMWL_WL_HIGH,UNPARSEABLE_RELAY,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 25B5BC04A6B
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 12:20:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D123021530
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 12:20:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="rwrtMH5v"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D123021530
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 586F76B0278; Wed,  8 May 2019 08:20:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5116C6B027A; Wed,  8 May 2019 08:20:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3D8E36B027C; Wed,  8 May 2019 08:20:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 031916B0278
	for <linux-mm@kvack.org>; Wed,  8 May 2019 08:20:42 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id y9so1681781plt.11
        for <linux-mm@kvack.org>; Wed, 08 May 2019 05:20:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=Vy0vJPC+R/qK4BTy9W8k2EK+1DkuBwwYmX4Im7RV/1I=;
        b=IqiUxr4VUfmK4FXQm0RWl/0FTDji7BxD/CZ0c1zJeLmlEZljnesjspUCqxvo64iXGc
         aHVpp85ldGHADE3leF3qoocac+n7gUYJefPWaldeAcHzgn2JbMPSXthzD1dD3B9hGUC9
         4FFSvc0ayO12R0+2QwYQSbGAtYIAx7tvWzImp/SO8LF2TAtOgDVzMLaorOlr4XzVPAKr
         GiWJioBREYFTn5KhQ/NnJMP+TzeWoAYgRkHc+j6p/MJ96qXqX7rSG79W6wBv77xogni0
         vuSjpud6lvI/MGZq7xj4H5GngPxWVsgpULpOms5221xulhNRst0nZhfbOSvcEngU3jLZ
         ahyQ==
X-Gm-Message-State: APjAAAUDp3/G3lqL6zylTBeYq4iuAYHxO0NhgdmsjA+wys0zekSTIgfL
	Uzj+oVGNjQawb9shG/IO6or5d8Dw+GQYwaHD3jifHC05keZxDR10tRwHcdLWZ2hPA/m3jaDGIL7
	rSzBMlUjA7MzpXSwhmibIwfR+64UeavcUGHwO9z78aHaFg02RT+17Wk8haHTGb82osA==
X-Received: by 2002:a63:1820:: with SMTP id y32mr46284127pgl.287.1557318041605;
        Wed, 08 May 2019 05:20:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxqzRLWNrgHi+s5Ip2wLQJPAvsTogDP8HVgj3j0VqLiswG1x3pCarv51D414eC4uzpjvEA8
X-Received: by 2002:a63:1820:: with SMTP id y32mr46284060pgl.287.1557318040706;
        Wed, 08 May 2019 05:20:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557318040; cv=none;
        d=google.com; s=arc-20160816;
        b=F6ZuVb5XxgP2F6K/aSOa4Bl978XbWjU9AW0880BvmnQMuFaFUX2WU1YAl4fmfUGf+u
         UijaQAGN+xe+zpx5UQD8DHXg8U8BvtCecOu/dNlTinvCSe9XrVrCn8o7M65osYx2f6Hy
         W3ZHDge3Lw6NcUUSrWSfWEN34djOZ2D4ye48Fha5NEVZlJNTmxMHWhmwOCFgeImPRorX
         BX81/F2/FGkU0Wp5W+Cjylmv2t/4ubBxfKMDUEI9JnXmIu2fC1E3K7GShHOg6NuHjkY7
         7aHzA+ELE+Wnsi8Ylh0rBU6qIOzl4bmsdcT4l4dCoccQ3mPkazams6MKP/RpKB0+/R+i
         7Mog==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=Vy0vJPC+R/qK4BTy9W8k2EK+1DkuBwwYmX4Im7RV/1I=;
        b=Une5N2yr/O9LVihUpQAcBJv5ESSkrWdhc/eGA90btLB3kBhHUqBEY3rKrAufW1Qnv+
         2aL4dN8NO0BdS9Br+Iae5gYEblkzjYmOLZBDrG8R5Kgj9JAgijPgRtVycwUlqrR/N7j/
         DZt7CQ45DdIrpTiKBq9iUxjFPRlijRN7BoLoyLIJNbQa/FTilvOnkOygQMWP+rI0NeKg
         RrFtzHnRd13NHjoixxIUOBJ3v8JdzXZFL4c/U5o0kzfTqzP6oJFqJVcoWRBKuwZOIfrR
         /1KDG+MgJiGwc1Pm90165uIG91XN2YsOQWB/BMggU/6L2VYGdYI+sxsLJKD8dyMlpfwm
         O4vA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=rwrtMH5v;
       spf=pass (google.com: domain of dan.carpenter@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=dan.carpenter@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id c13si23455058plo.175.2019.05.08.05.20.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 May 2019 05:20:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.carpenter@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=rwrtMH5v;
       spf=pass (google.com: domain of dan.carpenter@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=dan.carpenter@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x48CJBEV086953;
	Wed, 8 May 2019 12:20:31 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to : cc
 : subject : message-id : references : mime-version : content-type :
 in-reply-to; s=corp-2018-07-02;
 bh=Vy0vJPC+R/qK4BTy9W8k2EK+1DkuBwwYmX4Im7RV/1I=;
 b=rwrtMH5vFY76MnriFuwWJRty7cv6d48ndLvoH9qa0iSpe18cQhaRn84K+EEAZ1el4f/y
 JYXzNPHiRG6Um3c2LeXmrh0vIUgokB68rrApoaQDWIhQiq3xdWk5gSEBW5t2CsNm+NQD
 vMj6o0elaMb6F0MU58KC4FWtRSn89CRe22TBfRL7zCGITD8/HSnJoDvmL6xh8b//HGVN
 0/+i+9yb5Er16ot7xGaUWYdgVLnSKYTBDh5U+VgaaiAGanyy3YqtlO3+pRPaxxQxAHqK
 Taf9LSC6aD/fmeyve7zi016PT3fCR2HgfwqDVjH/4iBaBbfLBHPj+ptzQwZZXQN8uHEa Qg== 
Received: from userp3020.oracle.com (userp3020.oracle.com [156.151.31.79])
	by aserp2130.oracle.com with ESMTP id 2s94b63etg-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 08 May 2019 12:20:31 +0000
Received: from pps.filterd (userp3020.oracle.com [127.0.0.1])
	by userp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x48CJL8V107697;
	Wed, 8 May 2019 12:20:30 GMT
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by userp3020.oracle.com with ESMTP id 2s94ag20en-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 08 May 2019 12:20:30 +0000
Received: from abhmp0022.oracle.com (abhmp0022.oracle.com [141.146.116.28])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x48CKNew007185;
	Wed, 8 May 2019 12:20:24 GMT
Received: from kadam (/41.57.98.10)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 08 May 2019 05:20:22 -0700
Date: Wed, 8 May 2019 15:20:10 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
To: Alexandru Ardelean <alexandru.ardelean@analog.com>
Cc: linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org,
        linux-ide@vger.kernel.org, linux-clk@vger.kernel.org,
        linux-rpi-kernel@lists.infradead.org,
        linux-arm-kernel@lists.infradead.org,
        linux-rockchip@lists.infradead.org, linux-pm@vger.kernel.org,
        linux-gpio@vger.kernel.org, dri-devel@lists.freedesktop.org,
        intel-gfx@lists.freedesktop.org, linux-omap@vger.kernel.org,
        linux-mmc@vger.kernel.org, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, linux-pci@vger.kernel.org,
        linux-tegra@vger.kernel.org, devel@driverdev.osuosl.org,
        linux-usb@vger.kernel.org, kvm@vger.kernel.org,
        linux-fbdev@vger.kernel.org, linux-mtd@lists.infradead.org,
        cgroups@vger.kernel.org, linux-mm@kvack.org,
        linux-security-module@vger.kernel.org, linux-integrity@vger.kernel.org,
        alsa-devel@alsa-project.org, gregkh@linuxfoundation.org,
        andriy.shevchenko@linux.intel.com
Subject: Re: [PATCH 09/16] mmc: sdhci-xenon: use new match_string()
 helper/macro
Message-ID: <20190508122010.GC21059@kadam>
References: <20190508112842.11654-1-alexandru.ardelean@analog.com>
 <20190508112842.11654-11-alexandru.ardelean@analog.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190508112842.11654-11-alexandru.ardelean@analog.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9250 signatures=668686
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=644
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1905080079
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9250 signatures=668686
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=665 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1905080079
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 08, 2019 at 02:28:35PM +0300, Alexandru Ardelean wrote:
> -static const char * const phy_types[] = {
> -	"emmc 5.0 phy",
> -	"emmc 5.1 phy"
> -};
> -
>  enum xenon_phy_type_enum {
>  	EMMC_5_0_PHY,
>  	EMMC_5_1_PHY,
>  	NR_PHY_TYPES

There is no need for NR_PHY_TYPES now so you could remove that as well.

regards,
dan carpenter

