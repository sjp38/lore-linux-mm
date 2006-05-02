Content-class: urn:content-classes:message
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT
Subject: RE: [RFC 2/3] LVHPT - Setup LVHPT
Date: Tue, 2 May 2006 14:33:17 -0700
Message-ID: <B8E391BBE9FE384DAA4C5C003888BE6F06607EE1@scsmsx401.amr.corp.intel.com>
From: "Luck, Tony" <tony.luck@intel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ian Wienand <ianw@gelato.unsw.edu.au>
Cc: linux-ia64@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Yes that does seem a bit miss-leading.  I guess the point was that
> with short format you dedicate the top areas of your region to page
> tables for each process, with long format it is static.

So perhaps adding the word "virtual" (in between the "lower" and the
"memory") into the help description, and dropping the bit "when there
are a large number of processes in the system" would be clearer?

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
