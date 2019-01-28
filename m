Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 88D618E0001
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 02:04:32 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id v11so11216779ply.4
        for <linux-mm@kvack.org>; Sun, 27 Jan 2019 23:04:32 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id d8si8009638plo.196.2019.01.27.23.04.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 27 Jan 2019 23:04:31 -0800 (PST)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x0S73i0G080115
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 02:04:30 -0500
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2q9u01m2ge-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 02:04:30 -0500
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Mon, 28 Jan 2019 07:04:28 -0000
Date: Mon, 28 Jan 2019 09:04:22 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
Subject: [LSF/MM TOPIC]: mm documentation
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Message-Id: <20190128070421.GA2470@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lsf-pc@lists.linux-foundation.org
Cc: linux-mm@kvack.org

Hi,

At the last Plumbers plenary there was a discussion about the
documentation and one of the questions to the panel was "Is it better
to have outdated documentation or no documentation at all?" And, not
surprisingly, they've answered, "No documentation is better than
outdated".

The mm documentation is, well, not entirely up to date. We can opt for
dropping the outdated parts, which would generate a nice negative
diffstat, but identifying the outdated documentation requires nearly
as much effort as updating it, so I think that making and keeping
the docs up to date would be a better option.

I'd like to discuss what can be done process-wise to improve the
situation.

Some points I had in mind:

* Pay more attention to docs during review
* Set an expectation level for docs accompanying a changeset
* Add automation to aid spotting inconsistencies between the code and
  the docs
* Spend some cycles to review and update the existing docs
* Spend some more cycles to add new documentation

I'd appreciate a discussion about how we can get to the second edition
of "Understanding the Linux Virtual Memory Manager", what are the gaps
(although they are too many), and what would be the best way to close
these gaps.

-- 
Sincerely yours,
Mike.
