Message-ID: <20041204170217.45200.qmail@web53908.mail.yahoo.com>
Date: Sat, 4 Dec 2004 09:02:17 -0800 (PST)
From: Fawad Lateef <fawad_lateef@yahoo.com>
Subject: Re: Is sizeof(void *) ever != sizeof(unsigned long)?
In-Reply-To: <1102155752.1018.7.camel@desktop.cunninghams>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: ncunningham@linuxmail.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The sizeof(<pointer>) is always of 32bits or 4bytes on
x86 Architecture, and you can say that it is actually
the virtual address size of the Architecture. And
unsigned long is actually what I understand is the
size which a single architecture can address in a
single atempt, like roughly you can say that in x86
architecture long can be accesses in single cycle.

By defination, they can be not equal to each other but
practically it is same .........

Thanks and Regards,

Fawad 


		
__________________________________ 
Do you Yahoo!? 
Yahoo! Mail - now with 250MB free storage. Learn more.
http://info.mail.yahoo.com/mail_250
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
