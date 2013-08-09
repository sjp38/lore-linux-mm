Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id B0C386B0031
	for <linux-mm@kvack.org>; Fri,  9 Aug 2013 17:24:43 -0400 (EDT)
Received: by mail-vc0-f169.google.com with SMTP id ib11so1408793vcb.14
        for <linux-mm@kvack.org>; Fri, 09 Aug 2013 14:24:42 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CACz4_2cMSn1_DhVjN1ch60XDMSw1OxHjM+zh=+-iBtejgpHk8g@mail.gmail.com>
References: <1375582645-29274-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1375582645-29274-21-git-send-email-kirill.shutemov@linux.intel.com>
 <CACz4_2f2frTktfUusWGcaqZtTmQS8FSY0HqwXCas44EW7Q5Xsw@mail.gmail.com>
 <CACz4_2de=zm2-VtE=dFTfYjrdma4QFX1S-ukQ_7J4DZ32q1JQQ@mail.gmail.com>
 <CACz4_2fv1g2dRLh72gtaCYkNC6+Pp4h=R0q-taR51tejpL1gnw@mail.gmail.com>
 <20130809144601.159CAE0090@blue.fi.intel.com> <CACz4_2cMSn1_DhVjN1ch60XDMSw1OxHjM+zh=+-iBtejgpHk8g@mail.gmail.com>
From: Ning Qu <quning@google.com>
Date: Fri, 9 Aug 2013 14:24:22 -0700
Message-ID: <CACz4_2cb2vV4CdjnC8GNXZpVUNkAGVMZKZfMOxHCz+8R0XmVgg@mail.gmail.com>
Subject: Re: [PATCH 20/23] thp: handle file pages in split_huge_page()
Content-Type: multipart/alternative; boundary=047d7b342eae286ae004e38a6790
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Matthew Wilcox <willy@linux.intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-fsdevel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Al Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, Andi Kleen <ak@linux.intel.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Dave Hansen <dave@sr71.net>, linux-mm@kvack.org, Hillf Danton <dhillf@gmail.com>

--047d7b342eae286ae004e38a6790
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Does this look good to you? I want it to stay in this thread so I didn't
send it by git imap-send.

--047d7b342eae286ae004e38a6790--
