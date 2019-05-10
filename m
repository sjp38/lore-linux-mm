Return-Path: <SRS0=iTus=TK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 93468C04A6B
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 11:04:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2256021479
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 11:04:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="D51Bv0We"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2256021479
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 89C086B0279; Fri, 10 May 2019 07:04:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 873806B027A; Fri, 10 May 2019 07:04:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7611F6B027B; Fri, 10 May 2019 07:04:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3C7BF6B0279
	for <linux-mm@kvack.org>; Fri, 10 May 2019 07:04:00 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id g11so3890399pfq.7
        for <linux-mm@kvack.org>; Fri, 10 May 2019 04:04:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=CfM0QyoiD2lceMf/MJC3mMjfCfXAd2/bfEOAWv0cJ2Q=;
        b=myjFRpZerE6LjDP8qKnRpFNoyt2yyhUh0+2xpeJ0eoJ5SGYNPorodx5n3KSporzsRQ
         aTNRhBBlVMRWl8zYrdAKPPxRsLY0Xlxq0+MhTdI3mqLqJqXiwIu2HuE9Cj6vm2Luqvbp
         5Q7s0QEYoE5fUqfVIMSF6e8I9529cMzPjlEr1kisDwdrr/W23cVZn4SGK23b0gZearBu
         OAWF3+lpuiXo1UVRwAFH6+DEkMQ2s4v9YKyJ/kZ+nraeEcmNmx2fypZ7IiaEI1sEfXcq
         x+LtNAawpx+4g8x83l0Ja3G7E+zrj48VSw8set93hOfDwur9LiqTPj+t7jH5+5uep1t1
         lH0Q==
X-Gm-Message-State: APjAAAVjggVUMFtbn7SotEMIgyfgO8MdOZw0cFb4BiZtmLHDOr5KlCh+
	7UPOCfReFzy7ttp87WdyzAU6hDy6SInVHB4eDHB1XpGIuiUHrfmQm7zqFy6pmF7kwGUgp2nFXCp
	vSNjb029+azCI4+1Ss9UnUD0ZRLeOGW8Bx0wJIbJMvG/10DMR0fLGztsCt3chf1o0lA==
X-Received: by 2002:a62:5487:: with SMTP id i129mr13007978pfb.68.1557486239746;
        Fri, 10 May 2019 04:03:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz5KxhB2l8MJGuucDFQBCloUVqlxAXK4LCZ7BUErzEUvTQY47xjDV4tontxj9CtluxctDcb
X-Received: by 2002:a62:5487:: with SMTP id i129mr13007728pfb.68.1557486237314;
        Fri, 10 May 2019 04:03:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557486237; cv=none;
        d=google.com; s=arc-20160816;
        b=MhjsDsgN7+waYD/mitFTCo5025l364xyv603KSVyWwPfAOsXHE5WeJpfUIPvA91ycL
         x3KqMSh52Kw6adpC3pJ/LFhxLVoJDxWkkVrcGyuZv/aMsW9XGyPr0rPDEZoemma0Bm9b
         9y3g8BaEygfUO7Q3/o8GNvMaYOPQ/3LHmNDDugHTMPNgakskuojgBHLYSHVGPV2t7XIn
         6Tvz68dmYhV2OZPGWRDNZgDuwqSLnSX+loGndhY1s3FV9lT6cTVH+Bi6neE4HQYELwMu
         n4Ry9PtyghbkA4TsLGw90Yf78VBFbuFgZTOlSt1jzstMln2ztsYUWrf2zTcbU1YE18TP
         MUcA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=CfM0QyoiD2lceMf/MJC3mMjfCfXAd2/bfEOAWv0cJ2Q=;
        b=zPaq5tEoZ4zs3VksPJW2uP+8yOQYSH2OtuNnHoECEv+5wIUvcQbFrWSMnzVEwsEuSh
         WZ5SzIISxn0AMMfaVvZ2a2JAXsNcu/9hZI56mMeNf2v3GV5nZXt0hol8ZHRm79o5BCDC
         42U3QnpohzLpIn2FS8vk9Z8kXNxaeat2uWU0TPl8/FgwsIQNzMXKOskAays1pZVoD9Lr
         Ob2SIRcJq3pfXnyOEmA9D+q/ei293Od1NiignzmV2bQ4qO/L1QQBVSLzBGAkzL3ccwBp
         TnlEjSA6I3Bmmfhlsbr7sgTpv7woNdY2k3laO45THPqWSKdEKB5ChQoHUthul4lp89Q8
         U/CQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=D51Bv0We;
       spf=pass (google.com: domain of dan.carpenter@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=dan.carpenter@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id c11si6328471pll.205.2019.05.10.04.03.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 May 2019 04:03:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.carpenter@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=D51Bv0We;
       spf=pass (google.com: domain of dan.carpenter@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=dan.carpenter@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4AAx1NB144244;
	Fri, 10 May 2019 11:03:44 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to : cc
 : subject : message-id : references : mime-version : content-type :
 in-reply-to; s=corp-2018-07-02;
 bh=CfM0QyoiD2lceMf/MJC3mMjfCfXAd2/bfEOAWv0cJ2Q=;
 b=D51Bv0We8QTowc99zvTCIJuTCbSCXoc9B56Z8ExvQIyI9tdem+W93bgyBgMXVwunZ8pv
 4kxXOENcN94heTpPe2HdMrlJB2T3qCmEYwsZdQFLCZzVl7iwnIcB0+tOsj8a33pcDZ2b
 apaVZ8tiLXNzMfnoXrAtpjl+jnRLf4c9KQWuZg+PnEEgt/vdDBqRhVHpu/5TuzfI6BfK
 fi+8tUJU/aJFGtgdSqiKUrW3X2rQyYClgjiNr0e4R6bCAQx6tWNkz5Uq/nnWCSvgOzQY
 +Vw2Uu/Wf73/Oj/IUlLw1hBGhDnT3dAWjKij3V31FPg//vP2lgc79WQPCO9s4WRRuFde AQ== 
Received: from aserp3030.oracle.com (aserp3030.oracle.com [141.146.126.71])
	by userp2130.oracle.com with ESMTP id 2s94bggas0-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 10 May 2019 11:03:44 +0000
Received: from pps.filterd (aserp3030.oracle.com [127.0.0.1])
	by aserp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4AB16kE183844;
	Fri, 10 May 2019 11:01:43 GMT
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by aserp3030.oracle.com with ESMTP id 2scpy66rqg-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 10 May 2019 11:01:43 +0000
Received: from abhmp0020.oracle.com (abhmp0020.oracle.com [141.146.116.26])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x4AB1WHN021937;
	Fri, 10 May 2019 11:01:32 GMT
Received: from kadam (/41.57.98.10)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Fri, 10 May 2019 04:01:31 -0700
Date: Fri, 10 May 2019 14:01:17 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
To: "Ardelean, Alexandru" <alexandru.Ardelean@analog.com>
Cc: "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
        "linux-fbdev@vger.kernel.org" <linux-fbdev@vger.kernel.org>,
        "kvm@vger.kernel.org" <kvm@vger.kernel.org>,
        "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
        "alsa-devel@alsa-project.org" <alsa-devel@alsa-project.org>,
        "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
        "linux-mm@kvack.org" <linux-mm@kvack.org>,
        "linux-mtd@lists.infradead.org" <linux-mtd@lists.infradead.org>,
        "linux-clk@vger.kernel.org" <linux-clk@vger.kernel.org>,
        "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>,
        "andriy.shevchenko@linux.intel.com" <andriy.shevchenko@linux.intel.com>,
        "linux-rockchip@lists.infradead.org" <linux-rockchip@lists.infradead.org>,
        "linux-pm@vger.kernel.org" <linux-pm@vger.kernel.org>,
        "intel-gfx@lists.freedesktop.org" <intel-gfx@lists.freedesktop.org>,
        "linux-gpio@vger.kernel.org" <linux-gpio@vger.kernel.org>,
        "linux-rpi-kernel@lists.infradead.org" <linux-rpi-kernel@lists.infradead.org>,
        "linux-tegra@vger.kernel.org" <linux-tegra@vger.kernel.org>,
        "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>,
        "linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>,
        "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>,
        "linux-ide@vger.kernel.org" <linux-ide@vger.kernel.org>,
        "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
        "linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
        "linux-mmc@vger.kernel.org" <linux-mmc@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-security-module@vger.kernel.org" <linux-security-module@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-integrity@vger.kernel.org" <linux-integrity@vger.kernel.org>,
        "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>
Subject: Re: [PATCH 09/16] mmc: sdhci-xenon: use new match_string()
 helper/macro
Message-ID: <20190510110116.GB18105@kadam>
References: <20190508112842.11654-1-alexandru.ardelean@analog.com>
 <20190508112842.11654-11-alexandru.ardelean@analog.com>
 <20190508122010.GC21059@kadam>
 <2ec6812d6bf2f33860c7c816c641167a31eb2ed6.camel@analog.com>
 <31be52eb1a1abbc99a24729f5c65619235cb201f.camel@analog.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <31be52eb1a1abbc99a24729f5c65619235cb201f.camel@analog.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9252 signatures=668686
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=764
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1905100078
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9252 signatures=668686
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=796 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1905100078
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 10, 2019 at 09:13:26AM +0000, Ardelean, Alexandru wrote:
> On Wed, 2019-05-08 at 16:26 +0300, Alexandru Ardelean wrote:
> > On Wed, 2019-05-08 at 15:20 +0300, Dan Carpenter wrote:
> > > 
> > > 
> > > On Wed, May 08, 2019 at 02:28:35PM +0300, Alexandru Ardelean wrote:
> > > > -static const char * const phy_types[] = {
> > > > -     "emmc 5.0 phy",
> > > > -     "emmc 5.1 phy"
> > > > -};
> > > > -
> > > >  enum xenon_phy_type_enum {
> > > >       EMMC_5_0_PHY,
> > > >       EMMC_5_1_PHY,
> > > >       NR_PHY_TYPES
> > > 
> > > There is no need for NR_PHY_TYPES now so you could remove that as well.
> > > 
> > 
> > I thought the same.
> > The only reason to keep NR_PHY_TYPES, is for potential future patches,
> > where it would be just 1 addition
> > 
> >  enum xenon_phy_type_enum {
> >       EMMC_5_0_PHY,
> >       EMMC_5_1_PHY,
> > +      EMMC_5_2_PHY,
> >       NR_PHY_TYPES
> >   }
> > 
> > Depending on style/preference of how to do enums (allow comma on last
> > enum
> > or not allow comma on last enum value), adding new enum values woudl be 2
> > additions + 1 deletion lines.
> > 
> >  enum xenon_phy_type_enum {
> >       EMMC_5_0_PHY,
> > -      EMMC_5_1_PHY
> > +      EMM
> > C_5_1_PHY,
> > +      EMMC_5_2_PHY
> >  }
> > 
> > Either way (leave NR_PHY_TYPES or remove NR_PHY_TYPES) is fine from my
> > side.
> > 
> 
> Preference on this ?
> If no objection [nobody insists] I would keep.
> 
> I don't feel strongly about it [dropping NR_PHY_TYPES or not].

If you end up resending the series could you remove it, but if not then
it's not worth it.

regards,
dan carpenter

