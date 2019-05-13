Return-Path: <SRS0=GvbC=TN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 622CDC04AA7
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 23:06:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 02EBA20879
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 23:06:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 02EBA20879
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=mit.edu
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 854946B0003; Mon, 13 May 2019 19:06:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 804726B0005; Mon, 13 May 2019 19:06:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6F4DB6B0007; Mon, 13 May 2019 19:06:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4CA026B0003
	for <linux-mm@kvack.org>; Mon, 13 May 2019 19:06:48 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id d64so14243863qkg.20
        for <linux-mm@kvack.org>; Mon, 13 May 2019 16:06:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :subject:message-id:reply-to:mail-followup-to:mime-version
         :content-disposition:user-agent;
        bh=lDRFAUQrtyW4kpHrC8WhnYY1CpcvGqTdhl9uswTHvzU=;
        b=lrs4429zjcaM/r2LxE1mD/oW/E+BJvy3EvBEbfYPb3g4Ov9qSp2NNvfv2bJce14kVE
         Bdtud3KRhmAWy3ylaFv0IuXzxW0wZ8n7XRS8I9WRWH4qxtwGnPNycxPLbBaXPErmea7T
         vTz3pT2si3m9BhWZfOCB4LxxMkUUjRLbzK7ojmQ2G5+4Is04jXfEJKbo8esInTdAMO07
         Sxt7U68/y0PJpbhOOhrTV6hpdyoDc0VdYsNEEvwZJsuC5arleiyM4044hvMNMvoHUBwE
         WPsdtCBOXIy7Izk7kJ+5W6ePL6/5TTGVxUMWgX+7NeP03t5aoK44hhkFWAfOFzW7Lkuj
         MP1Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of tytso@mit.edu designates 18.9.28.11 as permitted sender) smtp.mailfrom=tytso@mit.edu
X-Gm-Message-State: APjAAAVisRhjPOY2F5AWxzl4dPPmYNbqwHZQzX2lblL0nC+UatQZ4R+o
	WnQY1GsmJKYZd0PekdQZAEFb4HhlL7iwSfZqaXVNNSci8aSiL0wbcoDr/n6AEdccFQ+WfminbeU
	akeCy1zVJpBmIi7psHjBEGfREu/X7fEJgK569+vzKOlyXbTAMDpg0wDze337Y/IJyyA==
X-Received: by 2002:ac8:3459:: with SMTP id v25mr27342855qtb.67.1557788807912;
        Mon, 13 May 2019 16:06:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzau1nYrAlEt9gtwO6G0ulWyDVWvZD/07EXENdmnFRt8FOqbOLjPansysIzwRHJwIRyGvhm
X-Received: by 2002:ac8:3459:: with SMTP id v25mr27342777qtb.67.1557788806962;
        Mon, 13 May 2019 16:06:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557788806; cv=none;
        d=google.com; s=arc-20160816;
        b=SP5A4svfeUQqDx8kqw3Wh7Z0mbRKg+CfQDWK0JVjFdPK5O0T930iqNo4RBEdRHl/Yg
         H2u/kW5f8x+SVi5L0Vng00FQIRfhBjabZ2P6p7t65/hLhyxlifi9FPoib2WrevQ0ud0n
         RXQ+eiX19XzD7+JHWNdT/Jsb6t7H2TT/06AyVAN2TB+lVdgq6IkN/6RC7HS4gDACAY2F
         k94VFJKDapgb7muJuplBGSzDJgXBXFxdcOUHjYHK5qYpXXLHjkQu4UJVCaZ4/m5ysAMF
         AZOLpEtGymiaHwC6wrtajb9sNWGPjCMsuoUI6vp9XS7D3msSP32ZT7iwIuyQbxVZ3Ui5
         paZg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-disposition:mime-version:mail-followup-to
         :reply-to:message-id:subject:to:from:date;
        bh=lDRFAUQrtyW4kpHrC8WhnYY1CpcvGqTdhl9uswTHvzU=;
        b=dAKy25ujrMd/jGD1cWyvNkxsAdgra+HVRyqVYiZ+6gq4bKjXx70OJbYKF1KFm26xvn
         ze84gxhsd7I1fsF8OC0DdnYVZiPkHcKVBMvtKjETruM7RGFfswXbOvt3Gfv81uxRO+pD
         dfrhK8NS2LfhXqHO9ifcpji+Ifo3X/WOMQWuS4mpsEOlZ4x38IbO0XUB7lK+voZBQ5NZ
         RkE9MHa4R9NuBoyFxjb898Eodu+n52O7r1dIb/7A97zKq6ero+61N6duFTmT/91XNvsR
         j2LgobOIgfW7btwa911AF+tus/iTwqc2xcwiSm1JMqJcV8MFLF+dT/+oPFoXNml7jGwB
         88oQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of tytso@mit.edu designates 18.9.28.11 as permitted sender) smtp.mailfrom=tytso@mit.edu
Received: from outgoing.mit.edu (outgoing-auth-1.mit.edu. [18.9.28.11])
        by mx.google.com with ESMTPS id j30si1565517qta.109.2019.05.13.16.06.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 May 2019 16:06:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of tytso@mit.edu designates 18.9.28.11 as permitted sender) client-ip=18.9.28.11;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of tytso@mit.edu designates 18.9.28.11 as permitted sender) smtp.mailfrom=tytso@mit.edu
Received: from callcc.thunk.org (rrcs-67-53-55-100.west.biz.rr.com [67.53.55.100])
	(authenticated bits=0)
        (User authenticated as tytso@ATHENA.MIT.EDU)
	by outgoing.mit.edu (8.14.7/8.12.4) with ESMTP id x4DN6hUY006602
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Mon, 13 May 2019 19:06:45 -0400
Received: by callcc.thunk.org (Postfix, from userid 15806)
	id 14F3A420024; Mon, 13 May 2019 19:06:43 -0400 (EDT)
Date: Mon, 13 May 2019 19:06:43 -0400
From: "Theodore Ts'o" <tytso@mit.edu>
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-mm@kvack.org, linux-block@vger.kernel.org,
        netdev@vger.kernel.org, ksummit-discuss@lists.linuxfoundation.org
Subject: Maintainer's / Kernel Summit 2019 planning kick-off
Message-ID: <20190513230643.GA4347@mit.edu>
Reply-To: tytso@mit.edu
Mail-Followup-To: tytso@mit.edu, linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-mm@kvack.org,
	linux-block@vger.kernel.org, netdev@vger.kernel.org,
	ksummit-discuss@lists.linuxfoundation.org
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

[ Feel free to forward this to other Linux kernel mailing lists as
  appropriate -- Ted ]

This year, the Maintainer's and Kernel Summit will be at the Corinthia
Hotel in Lisbon, Portugal, September 9th -- 12th.  The Kernel Summit
will be held as a track during the Linux Plumbers Conference
September 9th -- 11th.  The Maintainer's Summit will be held
afterwards, on September 12th.

As in previous years, the "Maintainer's Summit" is an invite-only,
half-day event, where the primary focus will be process issues around
Linux Kernel Development.  It will be limited to 30 invitees and a
handful of sponsored attendees.  This makes it smaller than the first
few kernel summits (which were limited to around 50 attendees).

The "Kernel Summit" is organized as a track which is run in parallel
with the other tracks at the Linux Plumber's Conference (LPC), and is
open to all registered attendees of LPC.

Linus has a generated a list of 18 people to use as a core list.  The
program committee will pick at least ten people from that list, and
then use the rest of Linus's list as a starting point of people to be
considered.  People who suggest topics that should be discussed on the
Maintainer's summit will also be added to the list for consideration.
To make topic suggestions for the Maintainer's Summit, please send
e-mail to the ksummit-discuss@lists.linuxfoundation.org list with a
subject prefix of [MAINTAINERS SUMMIT].

The other job of the program committee will be to organize the program
for the Kernel Summit.  The goal of the Kernel Summit track will be to
provide a forum to discuss specific technical issues that would be
easier to resolve in person than over e-mail.  The program committee
will also consider "information sharing" topics if they are clearly of
interest to the wider development community (i.e., advanced training
in topics that would be useful to kernel developers).

To suggest a topic for the Kernel Summit, please do two things.
First, please tag your e-mail with [TECH TOPIC].  As before, please
use a separate e-mail for each topic, and send the topic suggestions
to the ksummit-discuss list.

Secondly, please create a topic at the Linux Plumbers Conference
proposal submission site and target it to the Kernel Summit track.
For your convenience you can use:

	http://bit.ly/lpc19-submit

Please do both steps.  I'll try to notice if someone forgets one or
the other, but your chances of making your proposal gets the necessary
attention and consideration by submiting both to the mailing list and
the web site.

People who submit topic suggestions before May 31st and which are
accepted, will be given a free admission to the Linux Plumbers
Conference.

We will reserving roughly half of the Kernel Summit slots for
last-minute discussions that will be scheduled during the week of
Plumber's, in an "unconference style".  This allows ideas that come up
in hallway discussions, and in the LPC miniconferences, to be given
scheduled, dedicated times for discussion.

If you were not subscribed on to the kernel-discuss mailing list from
last year (or if you had removed yourself after the kernel summit),
you can subscribe to the discuss list using mailman:

   https://lists.linuxfoundation.org/mailman/listinfo/ksummit-discuss

The program committee this year is composed of the following people:

Greg Kroah-Hartman
Jens Axboe
Jon Corbet
Ted Ts'o
Thomas Gleixner

