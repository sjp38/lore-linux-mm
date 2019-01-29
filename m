Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0B886C169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 10:43:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BDD5A20881
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 10:43:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ArVVjMKW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BDD5A20881
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5B5678E0002; Tue, 29 Jan 2019 05:43:35 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5657A8E0001; Tue, 29 Jan 2019 05:43:35 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 47BB48E0002; Tue, 29 Jan 2019 05:43:35 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0A52F8E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 05:43:35 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id l76so16607485pfg.1
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 02:43:34 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=9rLaivmbx4MMF3WvUf1lfHL3bdxQKRE1GD54wVNSYzw=;
        b=kxm4+o3ejWPMJGbPO4mTr2LoTzuyAinw+To4R9o+R5fp8qigpcZHDf2zu2WRJJAGnZ
         AuEK5l2+U4kHlnOq1kzgUTjB6vKGue+cCejYeK0ov7FfNKYtVPH4mCY+mWLKMIKmDA8f
         aXySbz7yfC2G8ojAieNcP7/p2pvn+I9l5Hn+pphN8mQDgIJPPjXxDIZxQqSwWsP3qxip
         IB9cS5wSm7SNm8afr3fVnMBdr88gfLLBYmoEhif/THu1UD0sziGtMYSoTpNWBHvi4BTi
         rQP+Hor3kL1pD17AXRPOC3A+4SP4U5zQTWG/3jY5CKrsIRcL2Yq7WLjrU0OpLYJ0mVM2
         DWoA==
X-Gm-Message-State: AJcUukeXFTP4dw6+FFEbiefMaZtkoDubsNg0KQ5GheeR6ivtCzIuGpi8
	NcBbBUG3j6uFYyg48YWrP3XZneyzaV8HW0XWXWx3bYaavRhlggxqekOf2xMf8uaJDvS8VNEXJSZ
	NCgrxRVgr61ho2OQtlH+cDRfFMWvpX9z9yIFxPUfDnkYxEB/wj0yvxXYJhWbihj/kqgRQT+8YUm
	XdQLxymtZDwc4P1hbq522sK39fRhWzQMlXxAEp3gVUrvhCWXM99Ux+5G7lh6jvXhG8gMDCQ8PFa
	av0uov9BtDmbj68h8L4IzzQ+oh4Cinr8woMtgzzSVucNudUZ7qAT/6cpi2YAatJguyrI3X8spvl
	6nI/D6DqVECEc6s7LKf088BmpH7PhDXGfwxs606sFH3CcGqxYNZM3WjURkshEvo+Y0QTVZF07Wn
	l
X-Received: by 2002:a63:1d59:: with SMTP id d25mr23602079pgm.180.1548758614678;
        Tue, 29 Jan 2019 02:43:34 -0800 (PST)
X-Received: by 2002:a63:1d59:: with SMTP id d25mr23602048pgm.180.1548758613926;
        Tue, 29 Jan 2019 02:43:33 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548758613; cv=none;
        d=google.com; s=arc-20160816;
        b=njL/BAZRw2UE8YaWeHF9AuWxmQQnGJpL98Kp2ng8fssAE3i8U406mdSoixcNElCRDl
         QhTo+e3DzbJqFA+foojvPwFqAxiH/mdIemcVRr8sJwgav1PsQhgg/m1J7fK2thZurV30
         m5yd+Laic0pNJbWMPKHaV3so0NMcmZX3BSZI3K4qKczL66fr/Z0r977jVw3Fgpg0pVPj
         GdGHZFoObX4WLyc7vQANrn+hRwHhaCEEDAO5fUR13dB6dKR1yl3gQ0oqzD/OzYkbwf2x
         YDjgm0P9mjbWdOAYWXmElSD6YdPvZiRufyIFN0Z9GfJuRKixvlMYEJutofBM2anekGCx
         PW8A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=9rLaivmbx4MMF3WvUf1lfHL3bdxQKRE1GD54wVNSYzw=;
        b=Lz/mFrpq3r+YnT6FOjGa/Kb7xkBcs6Z9TZddzASviwg4Dv+HmOwoePJVU7vh7EgOZY
         oEish48s7CVC+0OFBppcT+ASuuzVWskXDVajjyM+KniflnnBEzHhBaaprFAdQiBMLvj+
         DJgCgMfnvFPJOg1jWaoIbmDx11NJ0kkjxj+0Mvp6eX3Ly1BAuY57VlOT9dK7/BshpPr7
         M4fqqnxkX3GP8ek9UfsCYLjIG8qMWl2taSFHvZleZ3jffJSbfzO+0QbyLVmpAuNazFIg
         s6+pyd4153PYGDqfr7JuCkRmfoPGTr00tEfdL39CCIFLy6rcgZi6/N7vKU5VjfvoBiI+
         bL5Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ArVVjMKW;
       spf=pass (google.com: domain of bsingharora@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=bsingharora@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a83sor53598890pfj.39.2019.01.29.02.43.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 29 Jan 2019 02:43:33 -0800 (PST)
Received-SPF: pass (google.com: domain of bsingharora@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ArVVjMKW;
       spf=pass (google.com: domain of bsingharora@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=bsingharora@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=9rLaivmbx4MMF3WvUf1lfHL3bdxQKRE1GD54wVNSYzw=;
        b=ArVVjMKWpGIEYJvaWP4VjVgZGTGHQCxGj4lciRI+U+4ARLHiRgoPO4JX+ugXQ6izbX
         0Hg6TJHCWS3nMiVTL7EPFWyyv37fmMg8xdlR1ZciLapCqbrFCYqp1zT1WpZGYTMqlmgd
         NKo1xErTQvNiVsxuInKoh5SmCFAV98Igj0Nnjwc71XxdZYM5h3lp28xRZR4N1G1/r9tW
         rbcf5Sy0+Djju85HTIG8wtke3nOytzBg8aunwPm2n4pSo+P++pn/CQmP4xvylrkaJRDk
         jBB+Gjqpu5e979WVSY2QLKkZOgy7ZHDIRyO8WCth0vYEeDfpLTn6APCs/MGkZDPkVLlu
         bccA==
X-Google-Smtp-Source: ALg8bN4ev0MdsOgHXgcPFSLJJx1qvBoa4F5pyfePhMtuOJ4F0UQnjzGi397cAHCb/t8BG1twqyQb/w==
X-Received: by 2002:a62:4851:: with SMTP id v78mr25847129pfa.97.1548758612632;
        Tue, 29 Jan 2019 02:43:32 -0800 (PST)
Received: from localhost (14-202-194-140.static.tpgi.com.au. [14.202.194.140])
        by smtp.gmail.com with ESMTPSA id d13sm75891877pfd.58.2019.01.29.02.43.31
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 29 Jan 2019 02:43:31 -0800 (PST)
Date: Tue, 29 Jan 2019 21:43:28 +1100
From: Balbir Singh <bsingharora@gmail.com>
To: Michal Hocko <mhocko@kernel.org>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org
Subject: Re: [LSF/MM TOPIC] Test cases to choose for demonstrating mm
 features or fixing mm bugs
Message-ID: <20190129104328.GJ26056@350D>
References: <20190128112033.GI26056@350D>
 <20190128113442.GG18811@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190128113442.GG18811@dhcp22.suse.cz>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jan 28, 2019 at 12:34:42PM +0100, Michal Hocko wrote:
> On Mon 28-01-19 22:20:33, Balbir Singh wrote:
> > Sending a patch to linux-mm today has become a complex task. One of the
> > reasons for the complexity is a lack of fundamental expectation of what
> > tests to run.
> > 
> > Mel Gorman has a set of tests [1], but there is no easy way to select
> > what tests to run. Some of them are proprietary (spec*), but others
> > have varying run times. A single line change may require hours or days
> > of testing, add to that complexity of configuration. It requires a lot
> > of tweaking and frequent test spawning to settle down on what to run,
> > what configuration to choose and benefit to show.
> > 
> > The proposal is to have a discussion on how to design a good sanity
> > test suite for the mm subsystem, which could potentially include
> > OOM test cases and known problem patterns with proposed changes
> 
> I am not sure I follow. So what is the problem you would like to solve.
> If tests are taking too long then there is a good reason for that most
> probably. Are you thinking of any specific tests which should be run or
> even included to MM tests or similar?

Let me elaborate, everytime I think I find something interesting, in terms
of something to develop/fix, I think of how to test the changes. I think
for well established code (such as reclaim) or even other features, it's hard
to find good test cases to run as a base to ensure that

1. There is good coverage of tests against the changes
2. The right test cases have been run from a performance perspective

The reason I brought up the time was not the time for a single test,
but all the tests cumulative in the absence of good guidance for
(1) and (2) above.

IOW, what guidance can we provide to patch writers and bug fixers in terms
of what testing to carry out? How do we avoid biases in results and
ensure consistency?

Balbir Singh.

