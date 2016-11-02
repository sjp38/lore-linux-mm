Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 90DD36B02BE
	for <linux-mm@kvack.org>; Wed,  2 Nov 2016 16:07:06 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id i34so25655293qkh.1
        for <linux-mm@kvack.org>; Wed, 02 Nov 2016 13:07:06 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n6si2026504qkh.73.2016.11.02.13.07.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Nov 2016 13:07:05 -0700 (PDT)
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 939537AE80
	for <linux-mm@kvack.org>; Wed,  2 Nov 2016 20:07:04 +0000 (UTC)
Received: from mail.random (ovpn-116-31.ams2.redhat.com [10.36.116.31])
	by int-mx10.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id uA2K72Bs009740
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO)
	for <linux-mm@kvack.org>; Wed, 2 Nov 2016 16:07:04 -0400
Date: Wed, 2 Nov 2016 21:07:02 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 00/33] userfaultfd tmpfs/hugetlbfs/non-cooperative
Message-ID: <20161102200702.GH4611@redhat.com>
References: <1478115245-32090-1-git-send-email-aarcange@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1478115245-32090-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

FYI: apparently I hit a git bug in this submit... reproducible with
the below command:

git send-email -1 --to '"what ever" <--your--@--email--.com>"'

after replacing --your--@email--.com with your own email.

/crypto/home/andrea/tmp/tmp/ftuVw5S7Vf/0001-userfaultfd-wp-use-uffd_wp-information-in-userfaultf.patch
Dry-OK. Log says:
Sendmail: /usr/sbin/sendmail *snip* -i --your--@--email--.com andrea@cpushare.com
From: Andrea Arcangeli <aarcange@redhat.com>
To: "what ever" " <--your--@--email--.com>
Subject: [PATCH 1/1] userfaultfd: wp: use uffd_wp information in userfaultfd_must_wait
Date: Wed,  2 Nov 2016 20:59:43 +0100
Message-Id: <1478116783-578-1-git-send-email-aarcange@redhat.com>
X-Mailer: git-send-email 2.7.3

Result: OK

It's not ok if the --dry-run outputs the above with a fine header, but
the actual header in the email data is different. Of course I tested
--dry-run twice and it was fine like the above is fine as well.

The submit is still valid for review so I'm not re-sending. I may
resend privately to Andrew post-review if needed.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
