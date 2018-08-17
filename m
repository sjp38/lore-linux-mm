Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id A3F926B076C
	for <linux-mm@kvack.org>; Fri, 17 Aug 2018 05:01:45 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id p132-v6so6595352itp.5
        for <linux-mm@kvack.org>; Fri, 17 Aug 2018 02:01:45 -0700 (PDT)
Received: from sonic302-21.consmr.mail.ne1.yahoo.com (sonic302-21.consmr.mail.ne1.yahoo.com. [66.163.186.147])
        by mx.google.com with ESMTPS id k203-v6si1081718iof.143.2018.08.17.02.01.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Aug 2018 02:01:44 -0700 (PDT)
Date: Fri, 17 Aug 2018 09:01:41 +0000 (UTC)
From: Thierry <reserv0@yahoo.com>
Reply-To: Thierry <reserv0@yahoo.com>
Message-ID: <328204943.8183321.1534496501208@mail.yahoo.com>
Subject: Re: [Bug 196157] New: 100+ times slower disk writes on
 4.x+/i386/16+RAM, compared to 3.x
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
References: <328204943.8183321.1534496501208.ref@mail.yahoo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alkis Georgopoulos <alkisg@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, reserv0@yahoo.com

Bug still present for 32 bits kernel in v4.18.1, and now, v4.1 (last working Linux kernel for 32 bits machines with 16Gb or more RAM) has gone unmaintained...
