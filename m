Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f175.google.com (mail-qc0-f175.google.com [209.85.216.175])
	by kanga.kvack.org (Postfix) with ESMTP id 60FFE6B0032
	for <linux-mm@kvack.org>; Thu, 30 Apr 2015 12:44:12 -0400 (EDT)
Received: by qcyk17 with SMTP id k17so31876280qcy.1
        for <linux-mm@kvack.org>; Thu, 30 Apr 2015 09:44:12 -0700 (PDT)
Received: from userp1040.oracle.com ([156.151.31.81])
        by mx.google.com with ESMTPS id w77si2216494qgw.25.2015.04.30.09.44.11
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Apr 2015 09:44:11 -0700 (PDT)
Message-ID: <55425BD1.4030009@oracle.com>
Date: Thu, 30 Apr 2015 12:44:01 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: [RFC 02/11] mm: debug: deal with a new family of MM pointers
References: <1429044993-1677-1-git-send-email-sasha.levin@oracle.com> <1429044993-1677-3-git-send-email-sasha.levin@oracle.com> <20150430161728.GA17344@node.dhcp.inet.fi>
In-Reply-To: <20150430161728.GA17344@node.dhcp.inet.fi>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org

On 04/30/2015 12:17 PM, Kirill A. Shutemov wrote:
> On Tue, Apr 14, 2015 at 04:56:24PM -0400, Sasha Levin wrote:
>> > This teaches our printing functions about a new family of MM pointer that it
>> > could now print.
>> > 
>> > I've picked %pZ because %pm and %pM were already taken, so I figured it
>> > doesn't really matter what we go with. We also have the option of stealing
>> > one of those two...
>> > 
>> > Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
>> > ---
>> >  lib/vsprintf.c |   13 +++++++++++++
>> >  1 file changed, 13 insertions(+)
>> > 
>> > diff --git a/lib/vsprintf.c b/lib/vsprintf.c
>> > index 8243e2f..809d19d 100644
>> > --- a/lib/vsprintf.c
>> > +++ b/lib/vsprintf.c
>> > @@ -1375,6 +1375,16 @@ char *comm_name(char *buf, char *end, struct task_struct *tsk,
>> >  	return string(buf, end, name, spec);
>> >  }
>> >  
>> > +static noinline_for_stack
>> > +char *mm_pointer(char *buf, char *end, struct task_struct *tsk,
>> > +		struct printf_spec spec, const char *fmt)
>> > +{
>> > +	switch (fmt[1]) {
> shouldn't we printout at least pointer address for unknown suffixes?

Sure, we can. We can also add a WARN() to make that failure obvious (there's
no reason to use an unrecognised %pZ* format on purpose).


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
