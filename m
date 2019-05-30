Return-Path: <SRS0=aa49=T6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 16512C46470
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 23:23:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BB02726310
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 23:23:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BB02726310
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=iki.fi
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 55FD86B027F; Thu, 30 May 2019 19:23:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 510B36B0280; Thu, 30 May 2019 19:23:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 400886B0281; Thu, 30 May 2019 19:23:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f71.google.com (mail-lf1-f71.google.com [209.85.167.71])
	by kanga.kvack.org (Postfix) with ESMTP id CF8DC6B027F
	for <linux-mm@kvack.org>; Thu, 30 May 2019 19:23:07 -0400 (EDT)
Received: by mail-lf1-f71.google.com with SMTP id z63so1644722lfa.16
        for <linux-mm@kvack.org>; Thu, 30 May 2019 16:23:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Jbp4kLkLF+l/eIOSlmHaTmZ4ybq5T0vxcNL1/2VNZ20=;
        b=R9oej1LXxwQl4xOnVWMzZJO7t9/0PAIUekxReGPIXbKFfzv98jin/Amii4n+EX34K1
         +Rc8kX0rC+SeJ8s9dcaairZtLaoSnmbDxo25ittyTopn7DQVfflCnGI0B7LqWf2T6p8V
         Z7fRlN2yEnxoWw1hQkG9eISaSFPFAnigq1RG2XslDvGb/h81jyIhYCGJaCwE64Wdo9eA
         W3E+pU6IE49geEira0NuLj+J6N5ohwLzTcEh7F7pANSyrBql4XfaLdIPSwvRn9395xLc
         Uz80Mm946pcoAtpDxHQpHahWw4vCmcxl3sd2ewqqCinnYyurSMf6bTqcUkBZGExS2+B5
         b2gQ==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 62.142.5.107 is neither permitted nor denied by domain of aaro.koskinen@iki.fi) smtp.mailfrom=aaro.koskinen@iki.fi;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=iki.fi
X-Gm-Message-State: APjAAAXdPJu+N/4PHR13NYTUBEAFsFp73iYew6k6Fv73Bhbdz2pUOdzD
	oSmYdMG0mCAYQ+qkMEQLXYvTOHkLZVPVHzinnWJ7iwYunIdFiD8A/SjrzVcVEt6bt/87FaRsAwL
	3KNjtanWwCF/491T0fGdMPmuIVLQdmtctHFiK4WC/RoOZXphauz2elq+igLhFxz4=
X-Received: by 2002:a2e:86d4:: with SMTP id n20mr468302ljj.210.1559258587202;
        Thu, 30 May 2019 16:23:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxrmtR5ngwh1OXwri9McfGSt8Xj5Q2M8OVzHMeUkELFOngQyXbQfUeaYn8KGyF4hHUrmoTS
X-Received: by 2002:a2e:86d4:: with SMTP id n20mr468273ljj.210.1559258586345;
        Thu, 30 May 2019 16:23:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559258586; cv=none;
        d=google.com; s=arc-20160816;
        b=qvIflJKwTN2+ebtTP8GWVr2tPbqSyhY1YoV+yPs3pwQf6FY+rD+50Y8scEk0iQv2+K
         p3CmzL6xk2o10KdNl8L7MvPd+Er+mk4WkVqZ7OkohI58J2TvAFNOXgYK4W3y0sKxV0Ce
         nTIPNCEBWbepWhkRy9gQFUWgQDvjIi6XoX1XtjC076/hrqx1j5KVoSjp7eX5NwgvhFLv
         VPzxHuSU8543VBl8GSx5jMj88eE5QOwUMNFH/ogBPN96ZYCOELIQCJT8UGaWPQuj5/hv
         pymh24wk9kGDJvoH85ZeIMrZB8+I5/1MGDGvkpZgTs252swiokVbJSroHBT3DfJeXJ+n
         XrJQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Jbp4kLkLF+l/eIOSlmHaTmZ4ybq5T0vxcNL1/2VNZ20=;
        b=PfmM6Ujb/9Xa6YoG7q/mQlAdiRrsRQSIdQudw0SjVU2wIZMERtgdmwxeMP9x/rLjbW
         yGcjbVO1oNJwbQgcfXj4AeM9L+ER6W32SyFXsbyQTA/VfbpGPBBaZg0OtSz4ClgcDN0N
         uSGdlkGZG4yXYExFAndWzqsz7RsulxTBhvK/fO5ebxWIrkP4Fju+WIOgI5+TP+k3Qjii
         bUhX7l0IqMGz8zY9g3ylYGfIR6Nz6Uenjmkx02UtJ1YM180Ujk1W/YMU9iFM30ORy2uj
         fDexhqBrHe/i7a0MjNl1+Tcve0BKnuNuYqGlkYbmyOoObyfIDrpIaXwUFhBOH+UeoOM/
         Gn0g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 62.142.5.107 is neither permitted nor denied by domain of aaro.koskinen@iki.fi) smtp.mailfrom=aaro.koskinen@iki.fi;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=iki.fi
Received: from emh01.mail.saunalahti.fi (emh01.mail.saunalahti.fi. [62.142.5.107])
        by mx.google.com with ESMTPS id d8si3699199ljl.213.2019.05.30.16.23.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 May 2019 16:23:06 -0700 (PDT)
Received-SPF: neutral (google.com: 62.142.5.107 is neither permitted nor denied by domain of aaro.koskinen@iki.fi) client-ip=62.142.5.107;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 62.142.5.107 is neither permitted nor denied by domain of aaro.koskinen@iki.fi) smtp.mailfrom=aaro.koskinen@iki.fi;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=iki.fi
Received: from darkstar.musicnaut.iki.fi (85-76-68-2-nat.elisa-mobile.fi [85.76.68.2])
	by emh01.mail.saunalahti.fi (Postfix) with ESMTP id 6CF7D20013;
	Fri, 31 May 2019 02:23:05 +0300 (EEST)
Date: Fri, 31 May 2019 02:23:05 +0300
From: Aaro Koskinen <aaro.koskinen@iki.fi>
To: Paul Burton <paul.burton@mips.com>
Cc: "linux-mips@vger.kernel.org" <linux-mips@vger.kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>
Subject: Re: MIPS/CI20: BUG: Bad page state
Message-ID: <20190530232305.GB4285@darkstar.musicnaut.iki.fi>
References: <20190424182012.GA21072@darkstar.musicnaut.iki.fi>
 <20190424192922.ilnn3oxc7ryzhd3l@pburton-laptop>
 <20190424204055.GB21072@darkstar.musicnaut.iki.fi>
 <20190424205016.yqtrlygqojii2rs6@pburton-laptop>
 <20190528233715.GB24195@darkstar.musicnaut.iki.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190528233715.GB24195@darkstar.musicnaut.iki.fi>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, May 29, 2019 at 02:37:15AM +0300, Aaro Koskinen wrote:
> On Wed, Apr 24, 2019 at 08:50:31PM +0000, Paul Burton wrote:
> > On Wed, Apr 24, 2019 at 11:40:55PM +0300, Aaro Koskinen wrote:
> > > On Wed, Apr 24, 2019 at 07:29:29PM +0000, Paul Burton wrote:
> > > > On Wed, Apr 24, 2019 at 09:20:12PM +0300, Aaro Koskinen wrote:
> > > > > I have been trying to get GCC bootstrap to pass on CI20 board, but it
> > > > > seems to always crash. Today, I finally got around connecting the serial
> > > > > console to see why, and it logged the below BUG.
> > > > > 
> > > > > I wonder if this is an actual bug, or is the hardware faulty?
> > > > > 
> > > > > FWIW, this is 32-bit board with 1 GB RAM. The rootfs is on MMC, as well
> > > > > as 2 GB + 2 GB swap files.
> > > > > 
> > > > > Kernel config is at the end of the mail.
> > > > 
> > > > I'd bet on memory corruption, though not necessarily faulty hardware.
> > > > 
> > > > Unfortunately memory corruption on Ci20 boards isn't uncommon... Someone
> > > > did make some tweaks to memory timings configured in the DDR controller
> > > > which improved things for them a while ago:
> > > > 
> > > >   https://github.com/MIPS/CI20_u-boot/pull/18
> > > > 
> > > > Would you be up for testing with those tweaks? I'd be happy to help with
> > > > updating U-Boot if needed.
> 
> I did some testing with CI20_u-boot ef995a1611f0, plus the timing fix
> cherry picked. Didn't help, I still get random crashes (every time
> different).

I have now ran memtester with 900M allocation for 10 hours (around 10
loops), then with two processes using 450M allocation each for 24 hours
(some 20 loops or so), and no errors or other issues are encountered.
I would guess if the timings were wrong, memtester would have failed
by now?

When trying GCC bootstrap the systems fails reliably... Usually within
few hours, but sometimes even within 30 minutes.

Maybe the issue is not memory/hardware. Since I build, and have also
swap, on MMC/SDcard perhaps we have some buggy code in the MMC or DMA
driver that results in memory corruption?

A.

