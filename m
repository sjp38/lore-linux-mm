Return-Path: <owner-linux-mm@kvack.org>
Date: Wed, 26 Jan 2011 15:46:07 -0500
From: Benjamin LaHaise <bcrl@kvack.org>
Subject: @google.com, @googlemail.com, @gmail.com bounces
Message-ID: <20110126204607.GG8066@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi folks,

Just to let people know, Google appears to be dropping emails that users 
of the domains in $SUBJ sent out.  Typical bounce messages are as follows:

Final-Recipient: rfc822; XXX@gmail.com
Original-Recipient: rfc822; linux-mm-outgoing
Action: failed
Status: 5.7.1
Remote-MTA: dns; gmail-smtp-in.l.google.com
Diagnostic-Code: smtp; 550 5.7.1 Unauthenticated email is not accepted from
    this domain. u12si37691121ibe.45

If someone at Google can get this investigated, it would be beneficial as 
that currently accounts for about 50% of the mailing list subscribers users 
of these domains are not reaching.

		-ben

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
