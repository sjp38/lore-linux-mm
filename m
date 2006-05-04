Content-class: urn:content-classes:message
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT
Subject: RE: [RFC 2/3] LVHPT - Setup LVHPT
Date: Thu, 4 May 2006 09:58:04 -0700
Message-ID: <B8E391BBE9FE384DAA4C5C003888BE6F06680039@scsmsx401.amr.corp.intel.com>
From: "Luck, Tony" <tony.luck@intel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ian Wienand <ianw@gelato.unsw.edu.au>, "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: linux-ia64@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Being relatively inexperienced, all this dynamic patching (SMP, page
> table, this) scares me in that what is executing diverges from what
> appears to be in source code, making difficult things even more
> difficult to debug.  Is there consensus that a long term goal should
> be that short and long formats should be dynamically selectable?

I wouldn't rule anything out until I see what can be done, and how
maintainable the code to do it is.  Perhaps someone will come up with
the ultimate in dynamic selection and use long format for some processes,
and short format for others (and thus get around the objections that
some workloads perform less well with long format).

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
