Message-ID: <20050522182229.20451.qmail@web25609.mail.ukl.yahoo.com>
Date: Sun, 22 May 2005 20:22:29 +0200 (CEST)
From: Vincenzo Mallozzi <vinjunior@yahoo.it>
Subject: set_fs(), get_fs and general protection fault
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi all,
I'm developing a module that checkpoints thread
processes.
In order to do the checkpoint, I use get_fs() and
set_fs() instructions. The way I use them is as
follow:

checkpoint_function()
{
   fs = get_fs();
   set_fs(KERNEL_DS);

   INSTRUCTIONS TO SAVE MEMORY DESCRIPTOR

   set_fs(fs);
}

restore_function()
{
   fs = get_fs();
   set_fs(KERNEL_DS);

   INSTRUCTIONS TO RESTORE MEMORY DESCRIPTOR

   set_fs(fs);
}

When I execute checkpoint_function(), all seems to go
well. 
But when I execute restore_function, a "general
protection fault" error is returned.
If I omit the instructions get_fs and set_fs, no error
of this type is returned (but the checkpoint does not
work well).
Can anyone help me on the usage of these instructions.
I've also found some previous emails regarding them,
but I've not well understood in which way get_fs and
set_fs must be applied in my module.
I've also read some checkpoint tools, e.g. CRACK, in
which they are used in about the same way I do it.
Thanks.
Vincenzo Mallozzi.


		
___________________________________ 
Nuovo Yahoo! Messenger: E' molto piu divertente: Audibles, Avatar, Giochi, Rubrica? Scaricalo ora! 
http://it.messenger.yahoo.it

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
