Received: from Relay2.suse.de (mail2.suse.de [195.135.221.8])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx2.suse.de (Postfix) with ESMTP id D95441D1E5
	for <linux-mm@kvack.org>; Sun, 16 Oct 2005 10:55:31 +0200 (CEST)
From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH] Add page migration support via swap to the NUMA policy layer
Date: Sun, 16 Oct 2005 10:56:06 +0200
MIME-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_nWhUD13y+u4+gSe"
Message-Id: <200510161056.07050.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--Boundary-00=_nWhUD13y+u4+gSe
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


[original mail had a mistyped linux-mm address]


--Boundary-00=_nWhUD13y+u4+gSe
Content-Type: message/rfc822;
  name="forwarded message"
Content-Transfer-Encoding: 7bit
Content-Description: Mail Delivery System <MAILER-DAEMON@suse.de>: Undelivered Mail Returned to Sender
Content-Disposition: inline

Return-Path: <>
Received: from imap.suse.de ([unix socket])
	by imap-dhs (Cyrus v2.1.16) with LMTP; Sun, 16 Oct 2005 10:44:52 +0200
X-Sieve: CMU Sieve 2.2
Received: from Relay2.suse.de (relay2.suse.de [149.44.160.89])
	(using TLSv1 with cipher EDH-RSA-DES-CBC3-SHA (168/168 bits))
	(Client CN "relay.suse.de", Issuer "SuSE Linux AG internal IMAP-Server CA" (verified OK))
	by imap.suse.de (Postfix) with ESMTP id E0C282D55F6
	for <ak@imap-dhs.suse.de>; Sun, 16 Oct 2005 10:44:52 +0200 (CEST)
Received: by Relay2.suse.de (Postfix)
	id D2C9223DB3; Sun, 16 Oct 2005 10:44:52 +0200 (CEST)
Received: from Relay2.suse.de (localhost [127.0.0.1])
	by Relay2.suse.de (Postfix) with ESMTP id C709F23CE1
	for <ak@suse.de>; Sun, 16 Oct 2005 10:44:52 +0200 (CEST)
Received: from Relay2.suse.de ([127.0.0.1])
 by Relay2.suse.de (Relay2 [127.0.0.1]) (amavisd-new, port 10026) with ESMTP
 id 28000-13 for <ak@suse.de>; Sun, 16 Oct 2005 10:44:52 +0200 (CEST)
Received: from mx2.suse.de (ns2.suse.de [195.135.220.15])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by Relay2.suse.de (Postfix) with ESMTP id 7D1311AB45
	for <ak@suse.de>; Sun, 16 Oct 2005 10:44:52 +0200 (CEST)
Received: by mx2.suse.de (Postfix)
	id 4F86A1CA66; Sun, 16 Oct 2005 10:44:52 +0200 (CEST)
Date: Sun, 16 Oct 2005 10:44:52 +0200 (CEST)
From: MAILER-DAEMON@suse.de (Mail Delivery System)
Subject: Undelivered Mail Returned to Sender
To: ak@suse.de
MIME-Version: 1.0
Content-Type: multipart/report;
  report-type=delivery-status;
  boundary="3FEF21CA39.1129452292/mx2.suse.de"
Message-Id: <20051016084452.4F86A1CA66@mx2.suse.de>
X-Virus-Scanned: by amavisd-new at Relay2.suse.de
X-Spam-Status: No, hits=-3.6 tagged_above=-20.0 required=5.0 tests=BAYES_00,
 MY_LINUX
X-Spam-Level: 
X-UID: 70378
X-Length: 5130

This is a MIME-encapsulated message.

--3FEF21CA39.1129452292/mx2.suse.de
Content-Description: Notification
Content-Type: text/plain

This is the Postfix program at host mx2.suse.de.

I'm sorry to have to inform you that your message could not be
be delivered to one or more recipients. It's attached below.

For further assistance, please send mail to <postmaster>

If you do so, please include this problem report. You can
delete your own text from the attached returned message.

			The Postfix program

<linux-mm@vger.kernel.org>: host vger.kernel.org[209.132.176.167] said: 554
    5.0.0 Hi [195.135.220.15], unresolvable address:
    <linux-mm@vger.kernel.org>; nosuchuser; linux-mm@vger.kernel.org (in reply
    to RCPT TO command)

--3FEF21CA39.1129452292/mx2.suse.de
Content-Description: Delivery report
Content-Type: message/delivery-status

Reporting-MTA: dns; mx2.suse.de
X-Postfix-Queue-ID: 3FEF21CA39
X-Postfix-Sender: rfc822; ak@suse.de
Arrival-Date: Sun, 16 Oct 2005 10:44:39 +0200 (CEST)

Final-Recipient: rfc822; linux-mm@vger.kernel.org
Action: failed
Status: 5.0.0
Diagnostic-Code: X-Postfix; host vger.kernel.org[209.132.176.167] said: 554
    5.0.0 Hi [195.135.220.15], unresolvable address:
    <linux-mm@vger.kernel.org>; nosuchuser; linux-mm@vger.kernel.org (in reply
    to RCPT TO command)

--3FEF21CA39.1129452292/mx2.suse.de
Content-Description: Undelivered Message
Content-Type: message/rfc822

Received: from Relay2.suse.de (mail2.suse.de [195.135.221.8])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx2.suse.de (Postfix) with ESMTP id 3FEF21CA39;
	Sun, 16 Oct 2005 10:44:39 +0200 (CEST)
From: Andi Kleen <ak@suse.de>
To: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: [PATCH] Add page migration support via swap to the NUMA policy layer
Date: Thu, 13 Oct 2005 20:47:03 +0200
User-Agent: KMail/1.8.2
Cc: lhms-devel@lists.sourceforge.net,
 linux-mm@vger.kernel.org
References: <Pine.LNX.4.62.0510131114140.14810@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.62.0510131114140.14810@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200510132047.03892.ak@suse.de>

On Thursday 13 October 2005 20:15, Christoph Lameter wrote:
> This patch adds page migration support to the NUMA policy layer. An additional
> flag MPOL_MF_MOVE is introduced for mbind. If MPOL_MF_MOVE is specified then
> pages that do not conform to the memory policy will be evicted from memory.
> When they get pages back in new pages will be allocated following the numa policy.

That part looks ok.

> 
> In addition this also adds a move_pages function that may be used from outside
> of the policy layer to move pages between nodes (needed by the cpuset support
> and the /proc interface). The design is intended to support future direct page
> migration without going through swap space.

Please split that out and resubmit if there are really other users

(what /proc support?) 

> +				WARN_ON(isolate_lru_page(page, pagelist) == 0);

WARN_ONs are not supposed to have side effects.

-Andi


--3FEF21CA39.1129452292/mx2.suse.de--

--Boundary-00=_nWhUD13y+u4+gSe--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
